# frozen_string_literal: true
class HomeController < AuthenticatedController

  def index
    @shop_origin = current_shopify_domain
  end

  def generate
    @invalid_names = flash[:invalid_promo_code_names] || []
    @prefixes_with_products = current_shop.prefixes.includes(:products).order(:name)

    if flash[:selected_code_settings].present?
      @selected_code_settings = flash[:selected_code_settings]
    end
  end
end
