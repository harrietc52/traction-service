# frozen_string_literal: true

module V1
  module Pacbio
    # RunResource
    class RunResource < JSONAPI::Resource
      model_name 'Pacbio::Run'

      attributes :name, :template_prep_kit_box_barcode, :binding_kit_box_barcode,
                 :sequencing_kit_box_barcode, :dna_control_complex_box_barcode,
                 :system_name, :created_at, :state, :comments, :all_wells_have_libraries

      has_one :plate, foreign_key_on: :related, foreign_key: 'pacbio_run_id'

      def created_at
        @model.created_at.to_s(:us)
      end

      def all_wells_have_libraries
        @model.all_wells_have_libraries?
      end
    end
  end
end
