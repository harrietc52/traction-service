# frozen_string_literal: true

module V1
  module Pacbio
    # WellsController
    class WellsController < ApplicationController
      def create
        @well_factory = ::Pacbio::WellFactory.new(params_names)
        if @well_factory.save
          @resources = @well_factory.wells.map { |well| WellResource.new(well, nil) }
          body = JSONAPI::ResourceSerializer.new(WellResource).serialize_to_hash(@resources)
          render json: body, status: :created
        else
          render json: { data: { errors: @well_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        @well_factory = ::Pacbio::WellFactory.new([param_names])
        @resources = @well_factory.wells.map { |well| WellResource.new(well, nil) }
        body = JSONAPI::ResourceSerializer.new(WellResource).serialize_to_hash(@resources)
        render json: body, status: :ok
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      def destroy
        well.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      private

      def param_names
        p1 = params.require(:data).require(:attributes)
                   .merge(id: params.require(:data)[:id])
                   .permit(
                     :movie_time, :insert_size, :row, :on_plate_loading_concentration,
                     :column, :comment, :sequencing_mode, :id
                   )

        if params.require(:data)[:relationships].present?
          p1[:libraries] = library_param_names(params.require(:data))
        end
        p1.to_h
      end

      def params_names
        params.require(:data).require(:attributes)[:wells].map do |param|
          well_params_names(param)
        end.flatten
      end

      def well_params_names(params)
        params.permit(:movie_time, :insert_size, :row,
                      :on_plate_loading_concentration, :column,
                      :comment, :sequencing_mode, :relationships).to_h.tap do |well|
          if params[:relationships].present?
            well[:plate] = plate_params_names(params)
            well[:libraries] = library_param_names(params) unless
            params.dig(:relationships, :libraries).nil?
          end
        end
      end

      def plate_params_names(params)
        params.require(:relationships)[:plate].require(:data).permit(:id, :type).to_h
      end

      def library_param_names(params)
        params.require(:relationships)[:libraries].require(:data).map do |library|
          library.permit(:id, :type).to_h
        end.flatten
      end

      def well
        @well ||= ::Pacbio::Well.find(params[:id])
      end

      def render_json(status)
        render json:
         JSONAPI::ResourceSerializer.new(WellResource)
                                    .serialize_to_hash(WellResource.new(@well, nil)), status: status
      end
    end
  end
end
