require 'csv'
class Code < ApplicationRecord

  ## CONSTANTS
  PER_PAGE = 250
  PER_PAGE_USED_CODES = 500
  SHIPPING_TYPES = {all: 'all', domestic: 'domestic', international: 'international'}

  ## VALIDATIONS
  validates :name, format: { with: CODE_NAME_REGEX }, allow_blank: true
  with_options presence: true do
    validates :name, uniqueness: { scope: [:prefix, :shop], allow_blank: true }
    validates :usage_limit, numericality: { greater_than_or_equal_to: Proc.new { |code| code.times_used  }, only_integer: true, allow_nil: true }
    validates :times_used, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: true }
    validates :products_in_order_limit, numericality: { greater_than_or_equal_to: 1, only_integer: true, allow_nil: true }
  end

  ## ASSOCIATIONS
  belongs_to :shop
  belongs_to :prefix
  belongs_to :setting
  has_many :orders
  has_many :shopify_orders, -> { where.not(shopify_id: nil) }, class_name: 'Order'
  has_many :products, through: :prefix
  accepts_nested_attributes_for :setting

  ## SCOPES
  scope :used, -> { where.not(times_used: 0) }
  scope :unused, -> { where(times_used: 0) }
  scope :usage_limit_exhausted, -> { where(arel_table[:times_used].gteq(arel_table[:usage_limit])) }
  scope :expired_codes, -> { where("expiry_date < ?", Time.current) }

  ## CALLBACKS
  before_validation :associate_prefix, if: :name?
  before_destroy :ensure_no_orders_are_present?

  ## CLASS METHODS
  def self.to_csv
    attributes = %w{name usage_limit times_used}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.includes(:shopify_orders).each do |code|
        code.order_data_with_detail_for(attributes, csv)
      end
    end
  end

  ## INSTANCE METHODS
  def limit_exceed?
    times_used >= usage_limit
  end

  def used
    update(times_used: times_used + 1)
  end

  def order_data_with_detail_for(attrs, csv)
    if has_shopify_orders?
      shop_url = shop.shopify_domain
      shopify_orders.each_with_index do |order, index|
        if index.zero?
          csv << attributes.values_at(*attrs) + [order.shopify_name, "https://#{shop_url}/admin/orders/#{order.shopify_id}"]
        else
          csv << [name, '', '', order.shopify_name, "https://#{shop_url}/admin/orders/#{order.shopify_id}"]
        end
      end
    else
      csv << attributes.values_at(*attrs)
    end
  end

  def shipping_countries
    if shipping_type == SHIPPING_TYPES[:domestic]
      Country.domestic
    elsif shipping_type == SHIPPING_TYPES[:international]
      Country.international
    else
      Country.all
    end
  end

  def shipping_type
    type = nil
    if setting.allow_domestic_shipping.present?
      type = SHIPPING_TYPES[:domestic]
      if setting.allow_international_shipping.present?
        type = SHIPPING_TYPES[:all]
      end
    elsif setting.allow_international_shipping.present?
      type = SHIPPING_TYPES[:international]
    end
    type
  end

  def get_errors
    if name.blank?
      "Please enter a code."
    elsif new_record?
      "Invalid Code #{name} entered."
    elsif limit_exceed? || (expiry_date.present? && (expiry_date.end_of_day < Time.current))
      "Code #{name} has expired."
    elsif prefix.products.published.size < 1
      "No product found for code #{name}"
    end
  end

  private def associate_prefix
    prefix_name = name.split('-')[0]
    self.prefix = shop.prefixes.find_or_initialize_by(name: prefix_name)
  end

  private def ensure_no_orders_are_present?
    if orders.present?
      errors.add(:base, :code_orders_present)
      throw :abort
    end
  end

  private def has_shopify_orders?
    shopify_orders.present?
  end

end
