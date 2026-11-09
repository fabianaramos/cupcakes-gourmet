class Product < ApplicationRecord
  SORTS = {
    "novidades"  => { created_at: :desc },
    "populares"  => { sold_count: :desc },
    "menor_preco" => { price: :asc },
    "maior_preco" => { price: :desc }
  }.freeze

  # RN US-006: a busca considera sinônimos e variações
  SYNONYMS = {
    "chocolate" => %w[cacau choco],
    "cacau" => %w[chocolate],
    "morango" => %w[morangos frutas],
    "vegano" => %w[vegana vegan],
    "sem gluten" => %w[sem\ glúten gluten-free],
    "limao" => %w[limão siciliano],
    "baunilha" => %w[vanilla]
  }.freeze

  belongs_to :category
  has_many :order_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :description, :ingredients, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "não pode ser negativo" }
  validates :min_stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :image_url, format: { with: %r{\Ahttps?://\S+\z}, message: "deve começar com http:// ou https://" }, allow_blank: true

  scope :available, -> { where(active: true).where("stock > 0") }
  scope :low_stock, -> { where("stock <= min_stock") }

  def self.search(term)
    term = term.to_s.strip.downcase
    return all if term.blank?

    terms = [ term ] + SYNONYMS.fetch(I18n.transliterate(term), [])
    clauses = terms.map { "(LOWER(products.name) LIKE ? OR LOWER(products.description) LIKE ? OR LOWER(products.ingredients) LIKE ?)" }
    values = terms.flat_map { |t| [ "%#{sanitize_sql_like(t)}%" ] * 3 }
    where(clauses.join(" OR "), *values)
  end

  def self.sorted(key)
    order(SORTS.fetch(key.to_s, SORTS["novidades"]))
  end

  def available? = active? && stock.positive?
  def low_stock? = stock <= min_stock

  def average_rating
    reviews.where(approved: true).average(:rating)&.round(1)
  end
end
