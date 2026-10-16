class PromoCodeGeneratesController < AuthenticatedController

  skip_before_action :verify_authenticity_token, if: :jwt_shopify_domain
  before_action :load_setting, only: :create

  def new
    @promo_code_generated_records = current_shop.promo_code_generated_records.order(created_at: :desc).paginate(page: params[:page], per_page: PromoCodeGeneratedRecord::PER_PAGE)
  end

  def create
    @promo_code_generated_record = current_shop.promo_code_generated_records.new
    @promo_code_generated_record.create_promo_codes(code_params, @setting)

    if @promo_code_generated_record.errors.present?
      flash[:error] = @promo_code_generated_record.errors.full_messages.to_sentence
    else
      flash[:notice] = t('.codes_creation_success')
    end
    redirect_to new_promo_code_generate_path and return
  end

  private def code_params
    params.permit(:prefix, :count, :usage_limit, :products_in_order_limit, :expiry_date, :add_complete_url_column)
  end

  private def setting_params
    params.permit(:allow_domestic_shipping, :has_free_domestic_shipping, :allow_international_shipping, :has_free_international_shipping)
  end

  private def load_setting
    @setting = Setting.find_or_initialize_by(setting_params.merge!(shop: current_shop))
    unless @setting.save
      flash[:error] = @setting.errors.full_messages.join(' ')
      redirect_to new_promo_code_generate_path and return
    end
  end

end
