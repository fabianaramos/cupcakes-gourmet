class Coupon < ApplicationRecord
  KINDS = %w[percentual fixo].freeze
  MAX_PERCENT = 50
  MAX_DISCOUNT_SHARE = 0.5 # RN US-009: desconto não pode ultrapassar 50% do total

  has_many :orders, dependent: :restrict_with_error

  normalizes :code, with: ->(c) { c.strip.upcase }

  validates :code, presence: true, uniqueness: { case_sensitive: false },
                   format: { with: /\A[A-Z0-9]+\z/, message: "deve ser alfanumérico (sem espaços)" }, length: { maximum: 30 }
  validates :kind, inclusion: { in: KINDS }
  validates :value, numericality: { greater_than: 0 }
  validates :value, numericality: { less_than_or_equal_to: MAX_PERCENT, message: "percentual máximo é 50%" }, if: -> { kind == "percentual" }
  validates :valid_until, presence: true
  validates :usage_limit, numericality: { only_integer: true, greater_than: 0 }

  def expired? = valid_until < Date.current
  def exhausted? = used_count >= usage_limit
  def usable? = active? && !expired? && !exhausted?

  def unusable_reason
    return "Cupom desativado." unless active?
    return "Cupom expirado." if expired?
    return "Cupom esgotado." if exhausted?
    nil
  end

  def discount_for(subtotal)
    raw = kind == "percentual" ? subtotal * value / 100 : value
    [ raw, subtotal * MAX_DISCOUNT_SHARE ].min.round(2)
  end

  def label = kind == "percentual" ? "#{value.to_i}%" : "R$ #{'%.2f' % value}".tr(".", ",")
end
