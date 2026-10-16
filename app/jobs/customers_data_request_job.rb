class CustomersDataRequestJob < ApplicationJob

  def perform(shop_domain: ,webhook:)
    temp = {type: 'customer_data_request', shop_domain: shop_domain, webhook: webhook}
    Bugsnag.notify(temp);

    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      send_customer_data(shop, webhook)
    end
  end

  def send_customer_data(shop, webhook)
    orders_csv_file_path = Order.generate_csv(shop, webhook[:customer][:email], webhook[:orders_requested])
    GdprMailer.send_customers_data_email(shop.id, orders_csv_file_path.to_s, webhook[:customer][:email]).deliver_later
  end

end
