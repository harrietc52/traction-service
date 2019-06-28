# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  belongs_to :material, inverse_of: :tube, polymorphic: true

  after_create :generate_barcode

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }

  private

  def generate_barcode
    update(barcode: "TRAC-#{id}")
  end
end
