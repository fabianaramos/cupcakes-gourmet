require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @client = create_client
    @product = create_product
    @order = place_order(@client, @product).order
  end

  test "US-013: avaliação só após entrega" do
    review = Review.new(order: @order, user: @client, product: @product, rating: 5)
    assert_not review.valid?
    3.times { @order.advance!(by: nil) }
    review.order.reload
    assert review.valid?, review.errors.full_messages.inspect
  end

  test "US-013 RNF#1: palavras impróprias bloqueadas e nota de 1 a 5" do
    3.times { @order.advance!(by: nil) }
    bad = @order.reviews.build(user: @client, product: @product, rating: 6, comment: "que lixo")
    assert_not bad.valid?
    assert bad.errors[:rating].any?
    assert bad.errors[:comment].any?
  end
end
