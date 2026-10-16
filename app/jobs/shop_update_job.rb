class ShopUpdateJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      shop.update_shopify_details(webhook)
    end
  end
end

