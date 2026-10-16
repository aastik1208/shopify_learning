require 'csv'
class Order < ApplicationRecord
  attr_accessor :province

  ## VALIDATIONS
  validates :first_name, :last_name, :address1, :city, :zip, :phone, :email, :shopify_state, :code, presence: true, unless: :redacted_at
  validates :variant_ids, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :ensure_code_not_expired, on: :create
  validate :ensure_products_are_published, on: :create
  validate :ensure_product_order_limit, on: :create, if: -> { code.present? && products.present? && variant_ids.present? }

  ## ASSOCIATIONS
  belongs_to :state, optional: true
  belongs_to :country
  belongs_to :shop
  belongs_to :code
  has_many :orders_product
  has_many :products, through: :orders_product, dependent: :destroy

  ## SCOPES
  scope :created_during, ->(from, to) { where(created_at: from..to) }

  ## CALLBACKS
  before_save :create_order, if: -> { shopify_id.nil? }
  after_save :create_expiration_token, if: -> { expiration_token.nil? }
  after_commit :update_associated_code_last_used_at, on: [:create, :update], if: :shopify_id_changed_from_nil?

  ## CLASS METHODS
  def self.generate_csv(shop, customer_email, shopify_ids_array)
    orders = shop.orders.where(email: customer_email).or(Order.where(shopify_id: shopify_ids_array)).includes(:state, :country, :products)
    csv_file_path = Rails.root.join("tmp/#{customer_email}_order.csv")

    CSV.open(csv_file_path, 'w') do |csv|
      csv << ['name', 'email', 'first_name', 'last_name', 'address1', 'address2', 'city', 'state_name', 'country_name', 'phone', 'products']
      orders.each do |order|
        csv << [order.shopify_name, order.email, order.first_name, order.last_name, order.address1, order.address2, order.city, order.state_name || order.state.name, order.country.name, order.phone, order.products.collect(&:shopify_title).join('; ')]
      end
    end

    csv_file_path
  end

  ## INSTANCE METHODS
  def ensure_code_not_expired
    error_message = code.get_errors
    if error_message.present?
      errors.add(:base, error_message)
    end
  end

  def ensure_products_are_published
    if products.present?
      products.each do |product|
        unless product.published
          errors.add(:base, :product_unavailable_reload)
          errors.add(:base, :product_unavailable, product_title: product.shopify_title)
        end
      end
    else
      errors.add(:base, :no_product_found)
    end
  end

  def ensure_product_order_limit
    product_limit = code.products_in_order_limit
    if products.size > product_limit || variant_ids.size > product_limit
      errors.add(:base, :product_limit_exceeded)
    elsif products.size != variant_ids.size
      errors.add(:base, :variants_incorrect)
    end
  end

  def province
    state.present? ? state.name : state_name
  end

  def shopify_state
    state_name || state
  end

  def create_order
    begin
      if valid?
        note  = title.blank? ? [] : [{ name: :customer_title, value: title }]
        note += cart_attributes.map{|key,value| {name: key, value: value}}.presence || []
        line_items_data = variant_ids.map { |variant_id| shopify_line_item(variant_id.to_i, code.name) }
        shop.with_shopify_session do
          @shopify_order = ShopifyAPI::Order.new(
            source_name: "Advance Promo Codes",
            email: email,
            customer: { first_name: first_name, last_name: last_name, email: email },
            billing_address: shopify_address,
            shipping_address: shopify_address,
            line_items: line_items_data,
            note_attributes: note,
            tags: code.name,
            inventory_behaviour: SHOPIFY_NEW_ORDER_INVENTORY_BEHABIOUR,
            financial_status: SHOPIFY_NEW_ORDER_FINANCIAL_STATUS,
            send_receipt: SHOPIFY_NEW_ORDER_SEND_RECEIPT
          )

          @shopify_order.save!
          self.shopify_id =  @shopify_order.id
          self.shopify_name = @shopify_order.name
          code.used
        end
      else
        errors.add(:base, errors.full_messages.to_sentence)
        throw :abort
      end

    rescue Exception => e
      if @shopify_order.present? && @shopify_order.errors.any?
        errors.add(:base, @shopify_order.errors.full_messages.join(','))
      else
        errors.add(:base, e.message)
      end
      Bugsnag.notify(e)
      throw :abort
    end
  end

  def shopify_line_item(variant_id, code_name)
    {
      variant_id: variant_id,
      quantity: 1,
      properties: {
        Code: code_name
      }
    }
  end

  def shopify_address
    {
      first_name: first_name,
      last_name: last_name,
      company: company,
      phone: phone,
      address1: address1,
      address2: address2,
      city: city,
      country_code: country.code,
      zip: zip,
      province: province
    }
  end

  def update_associated_code_last_used_at
    code.update(last_used_at: updated_at)
  end

  def shopify_id_changed_from_nil?
    old_value, new_value = saved_change_to_attribute(:shopify_id)
    old_value.blank? && new_value.present?
  end

  def create_expiration_token
    exp = Time.current.to_i + EXPIRATION_TOKEN_VALIDITY_DURATION.to_i
    payload = { order_id: id, exp: exp }
    token = JWT.encode payload, EXPIRATION_TOKEN_HMAC_SECRET, 'HS256'
    update_column(:expiration_token, token)
  end

  def has_expiration_token_expired?
    begin
      decoded_expiration_token = JWT.decode expiration_token, EXPIRATION_TOKEN_HMAC_SECRET, true, { algorithm: 'HS256' }
    rescue JWT::ExpiredSignature => exception
      return true
    end
    false
  end

end
