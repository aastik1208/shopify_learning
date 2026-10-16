class ShopRedactJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    temp = {type: 'shop_redact', shop_domain: shop_domain, webhook: webhook}

    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      destory_shop_and_its_associated_data(shop)
      Bugsnag.notify(temp);
    end
  end

  def destory_shop_and_its_associated_data(shop)
    shop.destroy
  end
end

