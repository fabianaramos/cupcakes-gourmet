require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "US-001 CA#1: e-mail deve ser único" do
    create_client(email: "a@teste.com")
    dup = User.new(name: "X", email: "A@teste.com", cpf: "11144477735", password: "senha1234")
    assert_not dup.valid?
    assert_includes dup.errors[:email], "já está em uso"
  end

  test "US-001 CA#2: senha do cliente exige 8 caracteres com letras e números" do
    %w[curta1 somenteletras 12345678].each do |pwd|
      u = User.new(name: "X", email: "x@teste.com", cpf: "11144477735", password: pwd)
      assert_not u.valid?, "#{pwd} deveria ser rejeitada"
    end
    assert User.new(name: "X", email: "x@teste.com", cpf: "11144477735", password: "senha1234").valid?
  end

  test "US-001 RN#1: CPF deve ser válido" do
    assert User.valid_cpf?("529.982.247-25")
    assert_not User.valid_cpf?("529.982.247-26")
    assert_not User.valid_cpf?("111.111.111-11")
    u = User.new(name: "X", email: "x@teste.com", cpf: "12345678900", password: "senha1234")
    assert_not u.valid?
    assert_includes u.errors[:cpf], "é inválido"
  end

  test "US-002 RN#1: cliente bloqueado por 15 min após 5 tentativas" do
    u = create_client
    4.times { u.register_failed_login! }
    assert_not u.locked?
    u.register_failed_login!
    assert u.locked?
    travel 16.minutes do
      assert_not u.reload.locked?
    end
  end

  test "US-021 RN#1/RN#2: admin precisa de e-mail corporativo e senha forte" do
    u = User.new(name: "A", email: "a@gmail.com", role: "admin", password: "fraca123")
    assert_not u.valid?
    assert u.errors[:email].any?
    assert u.errors[:password].any?
    assert User.new(name: "A", email: "a@#{User::CORPORATE_DOMAIN}", role: "admin", password: "Forte@12345").valid?
  end

  test "US-022 RN#1: admin bloqueado após 3 tentativas até desbloqueio" do
    a = create_admin
    3.times { a.register_failed_login! }
    assert a.locked?
    travel 1.day do
      assert a.reload.locked?, "continua bloqueado sem ação do superadmin"
    end
    a.unlock!
    assert_not a.locked?
  end
end
