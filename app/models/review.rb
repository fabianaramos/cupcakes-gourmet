class Review < ApplicationRecord
  BLOCKED_WORDS = %w[idiota lixo merda porcaria droga].freeze

  belongs_to :user
  belongs_to :product
  belongs_to :order

  validates :rating, numericality: { only_integer: true, in: 1..5, message: "deve ser de 1 a 5 estrelas" }
  validates :product_id, uniqueness: { scope: :order_id, message: "já foi avaliado neste pedido" }
  validate :buyer_must_have_received_product
  validate :no_offensive_words

  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }

  private

  def buyer_must_have_received_product
    return if order.nil? || product.nil?
    errors.add(:base, "Somente quem comprou pode avaliar.") unless order.user_id == user_id
    errors.add(:base, "A avaliação só é liberada após a entrega.") unless order.status == "entregue"
    errors.add(:base, "Este produto não está no pedido.") unless order.order_items.exists?(product_id: product_id)
  end

  def no_offensive_words
    text = I18n.transliterate(comment.to_s.downcase)
    errors.add(:comment, "contém palavras impróprias") if BLOCKED_WORDS.any? { |w| text.match?(/\b#{w}\b/) }
  end
end
