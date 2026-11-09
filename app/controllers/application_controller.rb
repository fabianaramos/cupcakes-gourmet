class ApplicationController < ActionController::Base
  CLIENT_TIMEOUT = 30.minutes # RN US-003
  STAFF_TIMEOUT = 15.minutes  # RN US-022#2

  allow_browser versions: :modern
  before_action :expire_idle_session
  helper_method :current_user, :logged_in?, :cart

  rescue_from Order::StatusError do |e|
    redirect_back fallback_location: root_path, alert: e.message
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in? = current_user.present?
  def cart = @cart ||= Cart.new(session)

  def sign_in(user)
    kept = session.to_hash.slice("cart", "coupon_code", "return_to")
    reset_session # evita fixação de sessão
    kept.each { |k, v| session[k] = v }
    session[:user_id] = user.id
    session[:last_seen_at] = Time.current.to_i
  end

  def sign_out
    reset_session
  end

  def expire_idle_session
    return unless session[:user_id]
    timeout = current_user&.staff? ? STAFF_TIMEOUT : CLIENT_TIMEOUT
    if session[:last_seen_at] && Time.at(session[:last_seen_at]) < timeout.ago
      staff = current_user&.staff?
      sign_out
      @current_user = nil
      flash[:alert] = "Sua sessão expirou por inatividade. Entre novamente."
      redirect_to(staff ? admin_login_path : login_path) and return
    end
    session[:last_seen_at] = Time.current.to_i
  end

  def require_client!
    return if current_user&.cliente?
    session[:return_to] = request.fullpath if request.get?
    redirect_to login_path, alert: "Entre na sua conta para continuar."
  end
end
