# frozen_string_literal: true

require_relative '../traction_graphql'
require 'graphql/rake_task'
require 'graphql-docs'

options = {
  schema_name: "TractionServiceSchema",
  directory: 'lib',
  idl_outfile: 'graphql_schema.graphql',
  json_outfile: 'graphql_schema.json'
}

GraphQL::RakeTask.new(options)

namespace :graphql do
  namespace :docs do
    task generate: :environment do
      GraphQLDocs.build(filename: File.join(options[:directory], options[:idl_outfile]))
    end
  end
end
