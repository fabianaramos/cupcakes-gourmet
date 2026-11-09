class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 60 }
  default_scope { order(:name) }
end
