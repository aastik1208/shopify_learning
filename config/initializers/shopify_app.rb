ShopifyApp.configure do |config|
  config.application_name = "Advance Promo Code App"
  config.api_key = ENV['shopify_application_api_key']
  config.secret = ENV['shopify_application_secret']
  config.scope = ENV['access_scopes']
  config.embedded_app = true
  config.enable_same_site_none = true
  config.after_authenticate_job = false
  config.shop_session_repository = Shop

  config.reauth_on_access_scope_changes = true
  config.allow_jwt_authentication = true
  # config.allow_cookie_authentication = false

  config.api_version = "2022-07"
  config.webhooks = [
    {topic: 'products/delete', address: ENV['app_host_address'] + '/webhooks/products_delete', fields: ['id'], format: 'json'},
    {topic: 'products/update', address: ENV['app_host_address'] + '/webhooks/products_update', fields: ['id', 'title', 'tags', 'handle', 'published_at'], format: 'json'},
    {topic: 'products/create', address: ENV['app_host_address'] + '/webhooks/products_create', format: 'json'},
    {topic: 'app/uninstalled', address: ENV['app_host_address'] + '/webhooks/app_uninstalled', format: 'json'},
    {topic: 'shop/update', address: ENV['app_host_address'] + '/webhooks/shop_update', format: 'json'},
  ]

end
