class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :item_name, :quantity, :unit_price, presence: true

  before_validation :calculate_total_price

  private

  def calculate_total_price
    self.quantity ||= 1
    self.unit_price ||= 0
    self.total_price = quantity.to_i * unit_price.to_f
  end
end