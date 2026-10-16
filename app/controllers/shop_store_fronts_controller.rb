class ShopStoreFrontsController < ActionController::Base

  before_action :fetch_shop
  before_action :fetch_code, only: :validate_code
  before_action :get_code, only: :fetch_products
  before_action :get_products, only: [:fetch_products, :validate_code]
  before_action :get_order, only: :order_validity_status

  include ShopifyApp::AppProxyVerification

  def validate_code
    @selected_product = @products.first
    response_params = { code: @code.name }
    render json: { 'redirect_link': @shop.store_link(STORE_PAGES[:products], response_params) } and return
  end

  def fetch_products
    @shipping_type = @code.shipping_type
    @free_shipping_for = @code.setting.free_shipping_for
    @collection_handle = @code.prefix.custom_collection_handle
    @products_limit = @code.products_in_order_limit

    @shipping_countries = @code.shipping_countries
    selected_country = @shipping_countries.first
    @states = selected_country.states.try(:order, :name)
    @show_inventory_count = @shop.show_inventory_count
    respond_to do |format|
      format.js { render 'fetch_products_via_collection', layout: false, content_type: 'application/liquid' and return }
    end
  end

  def order_validity_status
    if @order.has_expiration_token_expired?
      render json: { error: 'Etoken expired' }, status: 403 and return
    else
      respond_to do |format|
        format.js { render 'thank_you', layout: false, content_type: 'application/liquid' and return }
      end
    end
  end

  def orders
    sanitize_params
    if Date.parse(@shop.created_at.strftime("%Y-%m-%d")) > Date.parse("2023-01-11")
      Rails.logger.info("params: #{params}")
      Rails.logger.info("order params: #{order_params}")
      code_obj = Code.find_by_id(params['order']['code_id'])
      product_ids = params.dig('order', 'product_ids')  
      variant_ids =   params.dig('order', 'variant_ids')  
      if code_obj.present? && !code_obj.limit_exceed?
        NewShopOrderMailer.send_order_email_to_admin(@shop.id, order_params, variant_ids, product_ids).deliver_later
        render json: { redirect_link: @shop.store_link(STORE_PAGES[:new_thank_you]) }, status: 200
      else
        render json: { error: 'Invalid Code', error_messages: "Limit exceeded or invalid code" }, status: 422
      end
    else
      @order = Order.new(order_params.merge(shop_id: @shop.id))
      if @order.save
        response.headers['Expiration-Token'] = @order.expiration_token
        render json: { redirect_link: @shop.store_link(STORE_PAGES[:thank_you]) }, status: 200
      else
        render json: { error: 'Invalid Request', error_messages: @order.errors.messages }, status: 422
      end
    end
  end

  def states
    selected_country = Country.find_by(id: params[:selected_country_id].to_i)
    if selected_country.present?
      render json: selected_country.states.pluck(:id, :name).to_h.to_json
    else
      render json: { error: 'Invalid country id' }, status: 422
    end
  end

  private def render_404
    render file: Rails.root.join('public', '404.html'), status: 404 and return
  end

  private def render_422
    render file: Rails.root.join('public', '422.html'), status: 422 and return
  end

  private def fetch_shop
    @shop = Shop.find_by(shopify_domain: params[:shop])
    if @shop.blank?
      render_404
    end
  end

  private def fetch_code
    assign_code
    if @error = @code.get_errors
      render json: { error: @error }, status: 404 and return
    end
  end

  private def assign_code
    if params.has_key?(:code)
      @code = @shop.codes.find_or_initialize_by(name: code_params[:name].upcase)
    end
  end

  private def get_products
    @products = @code.prefix.products.order(:shopify_title).published
    if @products.size == 0
      render json: { error: 'No Products Found', redirect_link: @shop.store_link(STORE_PAGES[:code_search]) },
              status: 404 and return
    end
  end

  private def get_code
    assign_code
    if @error = @code.get_errors
      render json: { error: @error, redirect_link: @shop.store_link(STORE_PAGES[:code_search]) },
              status: 404 and return
    end
  end

  private def get_order
    @order = Order.find_by(expiration_token: params[:order][:expiration_token])
    if @order.blank?
      render json: { error: 'Invalid Token' }, status: 404 and return
    end
  end

  private def code_params
    params[:code][:name] = Rack::Utils.parse_query(params[:code][:name].strip)&.keys&.first
    params.require(:code).permit(:name)
  end

  private def prefix_params
    params[:prefix][:name] = Rack::Utils.parse_query(params[:prefix][:name].strip)&.keys&.first
    params.require(:prefix).permit(:name)
  end

  private def order_params
    params[:order][:product_ids] = params[:order][:product_ids]&.split(',')&.uniq
    params[:order][:variant_ids] = params[:order][:variant_ids]&.split(',')&.uniq
    params[:order][:cart_attributes] = params[:order][:attributes]
    params.require(:order).permit(:first_name, :last_name, :company, :title, :address1, :address2,
                                  :city, :country_id, :state_id, :state_name, :zip, :phone, :email,
                                  :code_id, product_ids: [], variant_ids: [], cart_attributes: {})
  end

  private def sanitize_params
    params[:order][:email].strip! if params[:order][:email].present?
  end

end
