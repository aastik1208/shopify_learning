class ThemeMailer < ApplicationMailer

  def theme_already_modified_email(shop_id)
    send_mail(shop_id)
  end

  def theme_modification_success_email(shop_id)
    send_mail(shop_id)
  end

  def theme_modification_failure_email(shop_id)
    send_mail(shop_id)
  end

  def theme_already_partially_modified_email(shop_id)
    send_mail(shop_id)
  end

  private def send_mail(shop_id)
    @shop = Shop.find_by(id: shop_id)

    if @shop.present?
      mail(to: @shop.shopify_email, subject: t('.subject', shop_name: @shop.name))
    end
  end

end
