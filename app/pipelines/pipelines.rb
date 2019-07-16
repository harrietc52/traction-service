# frozen_string_literal: true

# Pipelines
module Pipelines
  # InstanceMethodCreator
  module InstanceMethodCreator
    def create_instance_method(key, &block)
      self.class.send(:define_method, key, block)
    end
  end

  def self.configure(pipelines)
    Configuration.new(pipelines).tap do |configuration|
      configuration.pipelines.each do |pipeline|
        # TODO: how do I use the create_instance_method method
        self.class.send(:define_method, pipeline, proc { configuration.send(pipeline) })
      end
    end
  end

  def self.find(pipeline)
    send(pipeline.to_s.downcase)
  end
end
