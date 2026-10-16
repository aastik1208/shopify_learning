class ProductsCreateJob < ApplicationJob

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)
    required_attributes_names = ['id', 'title', 'handle', 'tags']
    shopify_product_attributes = webhook.select { |key, value| required_attributes_names.include? key }

    if shop.present?
      Product.create_new_shopify_product(webhook, shop)
    end
  end
end
