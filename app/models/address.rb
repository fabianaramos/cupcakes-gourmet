class Address < ApplicationRecord
  STATES = %w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO].freeze

  belongs_to :user
  has_many :orders, dependent: :restrict_with_error

  normalizes :cep, with: ->(c) { c.gsub(/\D/, "") }
  normalizes :state, with: ->(s) { s.strip.upcase }

  validates :cep, format: { with: /\A\d{8}\z/, message: "deve ter 8 dígitos" }
  validates :street, :number, :neighborhood, :city, presence: true
  validates :state, inclusion: { in: STATES, message: "inválido" }

  def to_s
    [ "#{street}, #{number}", complement.presence, neighborhood, "#{city}/#{state}", "CEP #{formatted_cep}" ].compact.join(" – ")
  end

  def formatted_cep = "#{cep[0, 5]}-#{cep[5, 3]}"
end
