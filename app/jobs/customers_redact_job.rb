class CustomersRedactJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    temp = {type: 'customer_redact', shop_domain: shop_domain, webhook: webhook}
    Bugsnag.notify(temp);

    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      redact_customer_data(webhook)
    end
  end

  def redact_customer_data(webhook)
    @orders = Order.where(email: webhook[:customer][:email]).or(Order.where(shopify_id: webhook[:orders_to_redact]))
    @orders.update_all(redacted_at: Time.current, first_name: nil, last_name: nil, address1: nil, address2: nil, city: nil, state_id: nil, state_name: nil, country_id: nil, zip: nil, email: nil, title: nil, company: nil, phone: nil)
  end
end

