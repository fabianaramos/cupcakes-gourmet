require "test_helper"

class CouponTest < ActiveSupport::TestCase
  def build(attrs = {})
    Coupon.new({ code: "PROMO10", kind: "percentual", value: 10, valid_until: Date.tomorrow, usage_limit: 2 }.merge(attrs))
  end

  test "US-020 RN#1: código alfanumérico" do
    assert_not build(code: "PROMO 10!").valid?
    assert build(code: "promo10").tap(&:valid?).code == "PROMO10"
  end

  test "US-020 RN#2: percentual máximo de 50%" do
    assert_not build(value: 60).valid?
    assert build(value: 50).valid?
  end

  test "US-009 RN#1: cupom expirado ou esgotado não é utilizável" do
    assert_not build(valid_until: Date.yesterday).usable?
    assert_not build(used_count: 2).usable?
    assert build.usable?
  end

  test "US-009 RN#2: desconto fixo não ultrapassa 50% do subtotal" do
    c = build(kind: "fixo", value: 30)
    assert_equal 20, c.discount_for(BigDecimal("40"))
    assert_equal 30, c.discount_for(BigDecimal("100"))
  end
end
