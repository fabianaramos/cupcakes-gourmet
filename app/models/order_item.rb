class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, in: 1..50 }
  validates :unit_price, numericality: { greater_than: 0 }

  def total = unit_price * quantity
end
