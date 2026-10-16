class ProductsUpdateJob < ApplicationJob

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      product = shop.products.find_by(shopify_id: webhook[:id])
      if product.present?
        product.update_shopify_details(webhook)
      end
    end
  end

end
