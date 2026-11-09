class Order < ApplicationRecord
  FLOW = %w[recebido confirmado em_preparo saiu_para_entrega entregue].freeze
  STATUSES = (FLOW + %w[cancelado]).freeze
  STATUS_LABELS = {
    "recebido" => "Recebido", "confirmado" => "Confirmado", "em_preparo" => "Em preparo",
    "saiu_para_entrega" => "Saiu para entrega", "entregue" => "Entregue", "cancelado" => "Cancelado"
  }.freeze
  PAYMENT_METHODS = { "pix" => "PIX", "cartao" => "Cartão de crédito", "boleto" => "Boleto" }.freeze
  PERIODS = { "manha" => "Manhã (8h–12h)", "tarde" => "Tarde (12h–18h)", "noite" => "Noite (18h–21h)" }.freeze
  MIN_SUBTOTAL = 25            # RN US-010
  INSTALLMENTS_MIN_TOTAL = 60  # RN US-011
  MAX_INSTALLMENTS = 3
  CLIENT_CANCELLABLE = %w[recebido confirmado].freeze # RN US-018
  FIXED_HOLIDAYS = %w[01-01 04-21 05-01 09-07 10-12 11-02 11-15 11-20 12-25].freeze

  belongs_to :user
  belongs_to :address
  belongs_to :coupon, optional: true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :status_changes, -> { order(:created_at, :id) }, class_name: "OrderStatusChange", dependent: :destroy
  has_many :reviews, dependent: :destroy

  before_validation :assign_number, on: :create

  validates :number, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS.keys, message: "selecione uma forma de pagamento" }
  validates :delivery_period, inclusion: { in: PERIODS.keys, message: "selecione uma faixa de horário" }
  validates :delivery_date, presence: { message: "selecione uma data" }
  validates :installments, numericality: { only_integer: true, in: 1..MAX_INSTALLMENTS }
  validate :delivery_date_rules
  validate :installments_rules
  validate :minimum_subtotal, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where.not(status: %w[entregue cancelado]) }
  scope :counted_as_sale, -> { where.not(status: "cancelado") }

  def self.delivery_day?(date)
    !date.sunday? && !FIXED_HOLIDAYS.include?(date.strftime("%m-%d"))
  end

  def status_label = STATUS_LABELS[status]
  def payment_label = PAYMENT_METHODS[payment_method]
  def period_label = PERIODS[delivery_period]
  def cancelled? = status == "cancelado"
  def delivered? = status == "entregue"
  def paid? = paid_at.present?

  def next_status
    return nil if cancelled?
    FLOW[FLOW.index(status) + 1]
  end

  def cancellable_by_client? = CLIENT_CANCELLABLE.include?(status)

  # RN US-016: segue o fluxo sem pular etapas; pedido cancelado não muda.
  def advance!(by:)
    target = next_status
    raise StatusError, "Pedido cancelado não pode ter o status alterado." if cancelled?
    raise StatusError, "Pedido já foi entregue." if target.nil?
    raise StatusError, "Aguardando confirmação do pagamento." if status == "recebido" && !paid? && by&.cliente?

    transaction do
      self.paid_at ||= Time.current if target == "confirmado"
      record_status!(target, by)
    end
  end

  def cancel!(by:)
    raise StatusError, "Pedido já está cancelado." if cancelled?
    if by.cliente? && !cancellable_by_client?
      raise StatusError, "Pedidos em preparo ou posteriores não podem ser cancelados pelo cliente."
    end
    raise StatusError, "Pedido entregue não pode ser cancelado." if delivered?

    transaction do
      order_items.includes(:product).each do |item|
        item.product.increment!(:stock, item.quantity)
        item.product.decrement!(:sold_count, item.quantity)
      end
      coupon&.decrement!(:used_count)
      record_status!("cancelado", by)
    end
  end

  def refund_message
    return nil unless cancelled? && paid?
    case payment_method
    when "cartao" then "Estorno no cartão em até 7 dias úteis."
    when "pix" then "Estorno via PIX iniciado automaticamente."
    else "Estorno do boleto será feito por transferência."
    end
  end

  def record_status!(target, by)
    from = status
    update!(status: target)
    status_changes.create!(from_status: from, to_status: target, user: by, created_at: Time.current)
  end

  class StatusError < StandardError; end

  private

  def assign_number
    self.number ||= loop do
      candidate = "CP#{Time.current.strftime('%y%m%d')}#{SecureRandom.random_number(10**5).to_s.rjust(5, '0')}"
      break candidate unless Order.exists?(number: candidate)
    end
  end

  # RN US-019: entrega a partir do dia seguinte, sem domingos e feriados
  def delivery_date_rules
    return if delivery_date.blank? || persisted?
    errors.add(:delivery_date, "deve ser a partir de amanhã") if delivery_date <= Date.current
    errors.add(:delivery_date, "não pode ser domingo ou feriado") unless self.class.delivery_day?(delivery_date)
    errors.add(:delivery_date, "deve estar nos próximos 30 dias") if delivery_date > 30.days.from_now.to_date
  end

  def installments_rules
    return if installments.to_i <= 1
    errors.add(:installments, "só é permitido no cartão de crédito") unless payment_method == "cartao"
    errors.add(:installments, "só para compras acima de R$ 60,00") if total.to_d <= INSTALLMENTS_MIN_TOTAL
  end

  def minimum_subtotal
    errors.add(:base, "O pedido mínimo é de R$ 25,00.") if subtotal.to_d < MIN_SUBTOTAL
  end
end
