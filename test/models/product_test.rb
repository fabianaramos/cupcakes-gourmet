require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "US-014 RN#1/RN#2: nome único e preço maior que zero" do
    create_product(name: "Red Velvet")
    p = Product.new(name: "red velvet", price: 0, description: "x", ingredients: "y", category: Category.first)
    assert_not p.valid?
    assert p.errors[:name].any?
    assert p.errors[:price].any?
  end

  test "US-015 RN#2: estoque não pode ser negativo" do
    p = create_product
    assert_not p.update(stock: -1)
  end

  test "US-004 RN#1 / US-015 CA#2: vitrine mostra só ativos com estoque" do
    visible = create_product
    create_product(stock: 0)
    create_product(active: false)
    assert_equal [ visible ], Product.available.to_a
  end

  test "US-015 RN#1: alerta de estoque baixo pelo mínimo (padrão 10)" do
    assert create_product(stock: 10).low_stock?
    assert_not create_product(stock: 11).low_stock?
  end

  test "US-006: busca por termo parcial, ingrediente e sinônimo" do
    choc = create_product(name: "Chocolate Belga", ingredients: "cacau, ovos")
    morango = create_product(name: "Frutas Vermelhas", ingredients: "morango, framboesa")
    assert_includes Product.search("choco"), choc
    assert_includes Product.search("framboesa"), morango
    assert_includes Product.search("cacau"), choc
    assert_empty Product.search("abacaxi")
  end
end
