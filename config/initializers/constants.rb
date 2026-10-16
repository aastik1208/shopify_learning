PREFIX_NAME_REGEX = /\A[A-Z]{3}\z/
CODE_NAME_REGEX = /\A[A-Z]{3}\-[A-Za-z0-9\.\!\#\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+(@[A-Za-z\.\-]+)?\Z/
PROMO_CODE_TAG_PREFIX = 'code prefix' # this is case insensitive
PRODUCT_TAG_REGEX = /^#{PROMO_CODE_TAG_PREFIX}: [A-Z]{3}$/i

SHOPIFY_NEW_ORDER_INVENTORY_BEHABIOUR = 'decrement_obeying_policy'.freeze
SHOPIFY_NEW_ORDER_FINANCIAL_STATUS = 'paid'.freeze
SHOPIFY_NEW_ORDER_SEND_RECEIPT = true.freeze
EXPIRATION_TOKEN_HMAC_SECRET = ENV['order_expiration_token_hmac_secret'].freeze
EXPIRATION_TOKEN_VALIDITY_DURATION = 7.days.freeze

SHOPIFY_FILES_PATHS = {
  code_styles: 'assets/advance_code_styles.css',
  collection_promo_code: 'templates/collection.advance_promo_code.liquid',
  page_code_search: 'templates/page.advance_code_search.liquid',
  page_code_show_products: 'templates/page.advance_code_show_products.liquid',
  page_code_thank_you: 'templates/page.advance_code_thank_you.liquid',
  page_code_new_thank_you: 'templates/page.advance_code_new_thank_you.liquid'
}.freeze

APP_FILE_PATHS = {
  code_styles: Rails.root.join('lib', 'theme_modifications', 'advance_code_styles.css'),
  collection_promo_code: Rails.root.join('lib', 'theme_modifications', 'collection.advance_promo_code.liquid'),
  page_code_search: Rails.root.join('lib', 'theme_modifications', 'page.advance_code_search.liquid'),
  page_code_show_products: Rails.root.join('lib', 'theme_modifications', 'page.advance_code_show_products.liquid'),
  page_code_thank_you: Rails.root.join('lib', 'theme_modifications', 'page.advance_code_thank_you.liquid'),
  page_code_new_thank_you: Rails.root.join('lib', 'theme_modifications', 'page.advance_code_new_thank_you.liquid')
}.freeze

CODE_PAGES_ATTRIBUTE_VALUES = [
  { title: 'Advance Code Store', handle: 'advance-code-store', template_suffix: 'advance_code_search' },
  { title: 'Advance Code Products', handle: 'advance-code-products', template_suffix: 'advance_code_show_products' },
  { title: 'Advance Code Thank You', handle: 'advance-code-thank-you', template_suffix: 'advance_code_thank_you' },
  { title: 'Advance Code New Thank You', handle: 'advance-code-new-thank-you', template_suffix: 'advance_code_new_thank_you' }
].freeze

STORE_PAGES = {
  code_search: "/pages/advance-code-store",
  products: "/pages/advance-code-products",
  thank_you: "/pages/advance-code-thank-you",
  new_thank_you: "/pages/advance-code-new-thank-you"
}.freeze

PROMO_CODE_GENERATED_RECORD_TYPES = { unsuccessful: 0, generated: 1 }.freeze
CUSTOM_COLLECTION = { template_suffix: 'advance_promo_code', relation: 'equals', column: 'tag' }.freeze
