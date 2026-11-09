# Dados de demonstração. Execute: bin/rails db:seed
# As senhas abaixo são APENAS para ambiente de teste/demonstração.
puts "Criando dados de demonstração..."

super_admin = User.find_or_create_by!(email: "super@cupcakesgourmet.com.br") do |u|
  u.name = "Superadministrador"
  u.role = "superadmin"
  u.password = "Super@Cupcake2026"
end
User.find_or_create_by!(email: "admin@cupcakesgourmet.com.br") do |u|
  u.name = "Ana Administradora"
  u.role = "admin"
  u.password = "Admin@Cupcake2026"
end

cliente = User.find_or_create_by!(email: "cliente@teste.com") do |u|
  u.name = "Carla Cliente"
  u.cpf = "529.982.247-25"
  u.phone = "11999990000"
  u.password = "cliente123"
end
cliente.addresses.first_or_create!(cep: "01310100", street: "Av. Paulista", number: "1000", neighborhood: "Bela Vista", city: "São Paulo", state: "SP")

cats = %w[Tradicionais Gourmet Veganos Sem\ glúten].to_h { |n| [ n, Category.find_or_create_by!(name: n) ] }

[
  [ "Tradicionais", "Baunilha Clássico", 9.90, "Massa fofinha de baunilha com cobertura de buttercream.", "Farinha de trigo, ovos, leite, manteiga, açúcar, baunilha", "Glúten, ovos, leite", 40 ],
  [ "Tradicionais", "Chocolate Belga", 11.90, "Massa de cacau com ganache de chocolate belga 54%.", "Farinha de trigo, cacau, chocolate belga, ovos, leite, manteiga", "Glúten, ovos, leite, soja", 35 ],
  [ "Gourmet", "Red Velvet", 13.90, "Massa aveludada com cream cheese frosting.", "Farinha de trigo, cacau, buttermilk, cream cheese, ovos", "Glúten, ovos, leite", 25 ],
  [ "Gourmet", "Pistache com Frutas Vermelhas", 15.90, "Creme de pistache e geleia artesanal de morango e framboesa.", "Farinha de trigo, pistache, morango, framboesa, ovos, manteiga", "Glúten, ovos, leite, castanhas", 8 ],
  [ "Gourmet", "Limão Siciliano", 12.90, "Massa cítrica com curd de limão siciliano e merengue maçaricado.", "Farinha de trigo, limão siciliano, ovos, açúcar, manteiga", "Glúten, ovos, leite", 20 ],
  [ "Veganos", "Cenoura Vegana", 12.50, "Massa de cenoura com cobertura de chocolate 70% vegano.", "Farinha de trigo, cenoura, óleo de girassol, cacau, açúcar demerara", "Glúten", 18 ],
  [ "Sem glúten", "Brigadeiro Sem Glúten", 13.50, "Massa de farinha de arroz e amêndoas com brigadeiro gourmet.", "Farinha de arroz, farinha de amêndoas, chocolate, leite condensado, ovos", "Ovos, leite, amêndoas", 15 ]
].each do |cat, name, price, desc, ingr, allerg, stock|
  Product.find_or_create_by!(name: name) do |p|
    p.category = cats[cat]
    p.price = price
    p.description = desc
    p.ingredients = ingr
    p.allergens = allerg
    p.stock = stock
    p.active = true
  end
end

Coupon.find_or_create_by!(code: "BEMVINDO10") { |c| c.kind = "percentual"; c.value = 10; c.valid_until = 1.year.from_now.to_date }
Coupon.find_or_create_by!(code: "FRETE5") { |c| c.kind = "fixo"; c.value = 5; c.valid_until = 6.months.from_now.to_date }

puts "Pronto! Superadmin: #{super_admin.email} | Admin: admin@cupcakesgourmet.com.br | Cliente: cliente@teste.com"
