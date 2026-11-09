# Gateway de pagamento SIMULADO (ambiente acadêmico).
# - Cartão e PIX: aprovação imediata → pedido confirmado automaticamente (CA US-011#3).
# - Boleto: gera linha digitável com vencimento em 2 dias úteis; o admin confirma o pagamento.
# Nenhum dado de cartão é armazenado (RNF US-011#2).
class PaymentSimulator
  def initialize(order)
    @order = order
  end

  def process!
    case @order.payment_method
    when "pix"
      @order.update!(payment_code: pix_code)
      @order.advance!(by: nil)
    when "cartao"
      @order.update!(payment_code: "AUT#{SecureRandom.hex(4).upcase}")
      @order.advance!(by: nil)
    when "boleto"
      @order.update!(payment_code: boleto_line)
    end
  end

  def self.boleto_due_date(from = Date.current)
    date = from
    added = 0
    while added < 2
      date += 1
      added += 1 unless date.saturday? || date.sunday?
    end
    date
  end

  private

  def pix_code
    "00020126580014BR.GOV.BCB.PIX0136#{SecureRandom.uuid}5204000053039865406#{'%.2f' % @order.total}5802BR6304#{SecureRandom.hex(2).upcase}"
  end

  def boleto_line
    "34191.79001 01043.510047 91020.150008 #{rand(1..9)} #{(@order.total * 100).to_i.to_s.rjust(10, '0')}"
  end
end
