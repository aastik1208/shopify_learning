class Product < ApplicationRecord

  ## VALIDATIONS
  validates :shopify_id, :shopify_title, presence: true
  validates :shopify_id, uniqueness: { scope: :shop }

  ## ASSOCIATIONS
  belongs_to :shop
  has_many :prefixes_product
  has_many :prefixes, through: :prefixes_product, dependent: :destroy
  has_many :codes, through: :prefixes

  ## SCOPES
  scope :published, -> { where(published: true) }
  scope :with_prefixes, -> { includes(:prefixes).where.not(prefixes: {id: nil}) }

  ## CLASS METHODS
  def self.fetch_all_shopify_products(shop)
    begin
      shop.with_shopify_session do
        shopify_products = ShopifyAPI::Product.find(:all, params: {limit: 100})
        all_shopify_products = shopify_products
        while shopify_products.next_page?
          shopify_products = shopify_products.fetch_next_page
          all_shopify_products += shopify_products
        end

        all_shopify_products.each do |shopify_product|
          build_associated_product_with_prefixes(shopify_product.attributes, shop)
        end
        ## saving all build products with their associated prefixes
        shop.save
      end
    rescue Exception => exception
      Bugsnag.notify(exception)
      # re-add job in dj
      shop.enqueue_fetch_all_shopify_products_job
    end
  end

  def self.build_associated_product_with_prefixes(shopify_product_attributes, shop)
    built_product = shop.products.build(shopify_id: shopify_product_attributes[:id], shopify_title: shopify_product_attributes[:title], shopify_handle: shopify_product_attributes[:handle])
    unless shopify_product_attributes[:published_at]
      built_product.published = false;
    end
    promo_code_tags = shopify_product_attributes[:tags].split(',').map(&:strip).uniq.select { |tag| PRODUCT_TAG_REGEX.match(tag).present? }

    promo_code_tags.each do |tag|
      prefix_name = tag[-3..-1].upcase
      if PREFIX_NAME_REGEX =~ (prefix_name)
        prefix_obj = shop.prefixes.select { |prefix| prefix if prefix.name == prefix_name }.first
        if prefix_obj.blank?
          prefix_obj = shop.prefixes.build(name: prefix_name)
        end
        built_product.prefixes << prefix_obj
      end
    end
  end

  def self.create_new_shopify_product(shopify_product_attributes, shop)
    build_associated_product_with_prefixes(shopify_product_attributes, shop)
    # saving built product and its associated prefix(es)
    shop.save
  end


  ## INSTANCE METHODS
  def update_shopify_details(shopify_details)
    update_shopify_title(shopify_details[:title])
    update_shopify_handle(shopify_details[:handle])
    update_shopify_published_status(shopify_details[:published_at])

    update_prefixes(shopify_details[:tags])
    self.save
  end

  private def update_shopify_title(new_shopify_title)
    self.shopify_title = new_shopify_title
  end

  private def update_shopify_handle(new_shopify_handle)
    self.shopify_handle = new_shopify_handle
  end

  private def update_shopify_published_status(shopify_published_at)
    self.published = shopify_published_at.present?
  end

  private def update_prefixes(shopify_tags)
    promo_code_tags = get_promo_code_tags(shopify_tags)
    latest_prefix_names = promo_code_tags.map { |tag| tag[-3..-1].upcase }.select { |prefix| PREFIX_NAME_REGEX =~ prefix }

    associated_prefix_objects = []
    latest_prefix_names.each do |prefix_name|
      associated_prefix_objects << shop.prefixes.find_or_initialize_by(name: prefix_name)
    end

    self.prefixes = associated_prefix_objects
  end

  private def get_promo_code_tags(shopify_product_tags)
    shopify_product_tags.split(',').map(&:strip).uniq.select { |tag| PRODUCT_TAG_REGEX.match(tag).present? }
  end

end
