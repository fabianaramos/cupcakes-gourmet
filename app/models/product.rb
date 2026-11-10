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
  validate :image_url_must_be_link_or_catalog_photo

  def self.catalog_photos
    Dir[Rails.root.join("app/assets/images/cupcakes/*.{jpg,jpeg,png,webp}")].map { |f| "cupcakes/#{File.basename(f)}" }.sort
  end

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

  private

  def image_url_must_be_link_or_catalog_photo
    return if image_url.blank? || image_url.match?(%r{\Ahttps?://\S+\z}) || self.class.catalog_photos.include?(image_url)
    errors.add(:image_url, "deve ser uma foto do catálogo ou um link começando com http:// ou https://")
  end
end
