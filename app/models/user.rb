class User < ApplicationRecord
  ROLES = %w[cliente admin superadmin].freeze
  CORPORATE_DOMAIN = "cupcakesgourmet.com.br".freeze
  CLIENT_MAX_ATTEMPTS = 5
  STAFF_MAX_ATTEMPTS = 3
  CLIENT_LOCK_TIME = 15.minutes

  has_secure_password

  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
  normalizes :cpf, with: ->(c) { c.gsub(/\D/, "") }
  normalizes :phone, with: ->(p) { p.gsub(/\D/, "") }

  validates :name, presence: true, length: { maximum: 120 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "não está em um formato válido" }
  validates :role, inclusion: { in: ROLES }
  validates :cpf, presence: true, if: :cliente?
  validates :cpf, uniqueness: true, allow_blank: true
  validate :cpf_must_be_valid, if: -> { cpf.present? }
  validate :password_strength, if: -> { password.present? }
  validate :corporate_email, if: :staff?

  scope :clientes, -> { where(role: "cliente") }
  scope :staff, -> { where(role: %w[admin superadmin]) }
  scope :pending_approval, -> { staff.where(approved: false) }

  def cliente? = role == "cliente"
  def staff? = %w[admin superadmin].include?(role)
  def superadmin? = role == "superadmin"
  def locked? = locked_until.present? && locked_until.future?
  def can_log_in? = !locked? && approved?

  def max_attempts = staff? ? STAFF_MAX_ATTEMPTS : CLIENT_MAX_ATTEMPTS

  # RN US-002: 5 tentativas → bloqueio de 15 min (cliente)
  # RN US-022: 3 tentativas → bloqueio até o superadministrador desbloquear (admin)
  def register_failed_login!
    self.failed_attempts += 1
    if failed_attempts >= max_attempts
      self.locked_until = staff? ? 100.years.from_now : CLIENT_LOCK_TIME.from_now
      self.failed_attempts = 0
    end
    save!(validate: false)
  end

  def register_successful_login!
    update_columns(failed_attempts: 0, locked_until: nil)
  end

  def unlock!
    update_columns(failed_attempts: 0, locked_until: nil)
  end

  def self.valid_cpf?(value)
    digits = value.to_s.gsub(/\D/, "")
    return false unless digits.length == 11
    return false if digits.chars.uniq.size == 1

    nums = digits.chars.map(&:to_i)
    check = lambda do |len|
      sum = nums.first(len).each_with_index.sum { |n, i| n * (len + 1 - i) }
      r = (sum * 10) % 11
      r == 10 ? 0 : r
    end
    check.call(9) == nums[9] && check.call(10) == nums[10]
  end

  private

  def cpf_must_be_valid
    errors.add(:cpf, "é inválido") unless self.class.valid_cpf?(cpf)
  end

  def password_strength
    if staff?
      unless password.length >= 10 && password =~ /[A-Za-z]/ && password =~ /\d/ && password =~ /[^A-Za-z0-9]/
        errors.add(:password, "deve ter no mínimo 10 caracteres, com letras, números e caractere especial")
      end
    else
      unless password.length >= 8 && password =~ /[A-Za-z]/ && password =~ /\d/
        errors.add(:password, "deve ter no mínimo 8 caracteres, com letras e números")
      end
    end
  end

  def corporate_email
    return if email.blank?
    errors.add(:email, "deve ser corporativo (@#{CORPORATE_DOMAIN})") unless email.end_with?("@#{CORPORATE_DOMAIN}")
  end
end
