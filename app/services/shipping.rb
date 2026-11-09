# Cálculo de frete simplificado por faixa de CEP (RN US-010#2).
module Shipping
  LOCAL_RANGE = (1_000_000..9_999_999).freeze # Grande São Paulo
  LOCAL_PRICE = BigDecimal("8.00")
  STATE_PRICE = BigDecimal("12.00")          # demais CEPs de SP (11000-000 a 19999-999)
  OTHER_PRICE = BigDecimal("18.00")

  def self.price_for(cep)
    n = cep.to_s.gsub(/\D/, "").to_i
    return LOCAL_PRICE if LOCAL_RANGE.cover?(n)
    return STATE_PRICE if (11_000_000..19_999_999).cover?(n)
    OTHER_PRICE
  end
end
