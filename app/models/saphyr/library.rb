# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Saphyr::Library
  # A saphyr library is a material
  # A saphyr library belongs to a saphyr request
  # A saphyr library belongs to a saphyr enzyme
  # A saphyr library can have many saphyr flowcells
  class Library < ApplicationRecord
    include Material
    include Librarian

    belongs_to :request, class_name: 'Saphyr::Request',
                         foreign_key: 'saphyr_request_id', inverse_of: false
    belongs_to :enzyme, class_name: 'Saphyr::Enzyme', foreign_key: 'saphyr_enzyme_id',
                        inverse_of: :libraries

    has_many :flowcells, class_name: 'Saphyr::Flowcell',
                         foreign_key: 'saphyr_library_id', inverse_of: :library,
                         dependent: :nullify
  end
end
