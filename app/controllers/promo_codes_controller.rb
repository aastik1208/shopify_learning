class PromoCodesController < AuthenticatedController

  skip_before_action :verify_authenticity_token, if: :jwt_shopify_domain
  skip_before_action :redirect_to_splash_page, only: [:generate, :generate_used_code, :generate_unused_code, :generate_exhausted_code, :generate_expired_code]
  before_action :ensure_promo_code_names_exists, only: :create
  before_action :load_setting, only: :create
  before_action :load_code, only: [:destroy, :edit, :update]

  def index
    @codes = current_shop.codes.order(created_at: :desc).includes(:setting, :shopify_orders).paginate(page: params[:page], per_page: Code::PER_PAGE)
    @used_codes = current_shop.codes.used.order(created_at: :desc).includes(:setting, :shopify_orders).paginate(page:1, per_page: Code::PER_PAGE_USED_CODES)
    @unused_codes = current_shop.codes.unused.order(created_at: :desc).includes(:setting, :shopify_orders).paginate(page:1, per_page: Code::PER_PAGE_USED_CODES)
    @usage_exhausted_codes = current_shop.codes.usage_limit_exhausted.order(created_at: :desc).includes(:setting, :shopify_orders).paginate(page:1, per_page: Code::PER_PAGE_USED_CODES)
    @expired_codes = current_shop.codes.expired_codes.order(created_at: :desc).includes(:setting, :shopify_orders).paginate(page:1, per_page: Code::PER_PAGE_USED_CODES)

    if @codes.size == 0 && params[:page] && params[:page] != 1
      redirect_to home_generate_path
    end
  end

  def create
    created, invalid, duplicate = @setting.create_promo_codes(code_params)
    if created.length > 0 or duplicate.length > 0
      success_message = t('.success', count: created.length)
      if duplicate.length > 0
        success_message += ' ' + t('.duplicate', count: duplicate.length)
      end
      flash[:notice] = success_message
    end

    if invalid.length > 0
      flash[:invalid_promo_code_names] = invalid
      set_code_settings_flash
      flash[:error] = t('.invalid', count: invalid.length)
    end
    redirect_to home_generate_path
  end

  def destroy
    if @code.destroy
      flash[:notice] = t('.success')
    else
      flash[:error] =  @code.errors.full_messages.join(' ') || t('.failure')
    end
    redirect_to promo_codes_path
  end

  def lookup
    @code = current_shop.codes.find_by(name: code_search_params[:code_name])
    if @code.present?
      redirect_to edit_promo_code_path(@code.id)
    else
      flash[:error] = t('.not_found')
      redirect_to search_path
    end
  end

  def edit
  end

  def update
    if @code.update(code_update_params)
      flash[:notice] = t('.success')
    else
      flash[:error] = t('.failure')
    end
    redirect_to promo_codes_path
  end

  def update_usage_limit
    update_amount = current_shop.usage_limit_update_amount
    current_shop.codes.each do |code|
      used_value = code.times_used
      if used_value > 0 && used_value + update_amount > code.usage_limit
        code.update(usage_limit: used_value + update_amount)
      end
    end
    redirect_to home_generate_path
  end

  def update_usage_limit_exhausted_only
    update_amount = current_shop.usage_limit_update_amount_for_exhausted
    current_shop.codes.each do |code|
      used_value = code.times_used
      if used_value > 0 && used_value == code.usage_limit
        code.update(usage_limit: used_value + update_amount)
      end
    end
    redirect_to home_generate_path
  end

  def generate
    @codes = current_shop.codes
    send_data @codes.to_csv, filename: t('.file_name', shop_name: current_shop.name)
  end

  def generate_used_code
    @codes = current_shop.codes.used
    send_data @codes.to_csv, filename: t('.file_name', shop_name: current_shop.name)
  end

  def generate_unused_code
    @codes = current_shop.codes.unused
    send_data @codes.to_csv, filename: t('.file_name', shop_name: current_shop.name)
  end

  def generate_exhausted_code
    @codes = current_shop.codes.usage_limit_exhausted
    send_data @codes.to_csv, filename: t('.file_name', shop_name: current_shop.name)
  end

  def generate_expired_code
    @codes = current_shop.codes.expired_codes
    send_data @codes.to_csv, filename: t('.file_name', shop_name: current_shop.name)
  end

  private def ensure_promo_code_names_exists
    if code_params[:names].blank?
      set_code_settings_flash
      flash[:error] = t('.atleast_one_code_required')
      redirect_to home_generate_path and return
    end
  end

  private def load_setting
    @setting = Setting.find_or_initialize_by(setting_params.merge!(shop: current_shop))
    unless @setting.save
      flash[:error] = @setting.errors.full_messages.join(' ')
      set_code_settings_flash
      redirect_to home_generate_path
    end
  end

  private def code_params
    params.require(:promo_code).permit( :names, :usage_limit, :products_in_order_limit, :expiry_date, :file)
  end

  private def setting_params
    params.require(:promo_code).permit(:allow_domestic_shipping, :has_free_domestic_shipping, :allow_international_shipping, :has_free_international_shipping)
  end

  private def load_code
    @code = current_shop.codes.find_by(id: params[:id])
    unless @code.present?
      flash[:error] = t('.not_found')
      redirect_to home_generate_path and return
    end
  end

  private def code_update_params
    params.require(:code).permit(:usage_limit, :products_in_order_limit, :expiry_date)
  end

  private def code_search_params
    params.permit(:code_name)
  end

  private def set_code_settings_flash
    flash[:selected_code_settings] = setting_params
  end

end
