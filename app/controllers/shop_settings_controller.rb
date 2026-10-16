class ShopSettingsController < AuthenticatedController

  skip_before_action :verify_authenticity_token, if: :jwt_shopify_domain

  def edit
  end

  def update
    if current_shop.update(edit_shop_setting_params)
      flash[:notice] = t('.shop_setting_successfully_updated')
      redirect_to edit_shop_setting_path(current_shop)
    else
      flash.now[:error] = current_shop.pretty_errors
      render :edit
    end
  end

  private def edit_shop_setting_params
    params.require(:shop).permit(:admin_emails, :usage_limit_update_amount, :usage_limit_update_amount_for_exhausted, :automate_usage_limit_update, :show_inventory_count)
  end

end
