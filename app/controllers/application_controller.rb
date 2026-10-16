# frozen_string_literal: true
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_shop
  helper :all
  after_action :set_security_header

  def current_shop
    @current_shop ||= Shop.find_by(shopify_domain:  current_shopify_domain)
  end

  protected

  def set_security_header
    response.headers['Content-Security-Policy'] = "frame-ancestors https://#{current_shopify_domain} https://admin.shopify.com;"
  end

end
