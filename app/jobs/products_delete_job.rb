class ProductsDeleteJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      shop.products.find_by(shopify_id: webhook[:id]).try(:destroy)
    end
  end
end
