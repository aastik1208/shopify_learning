class FetchAllShopifyProductsJob < ApplicationJob

  def perform(shop_id)
    shop = Shop.find_by(id: shop_id)

    if shop.present?
      Product.fetch_all_shopify_products(shop)
    end
  end
end
