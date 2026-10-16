# frozen_string_literal: true
class Shop < ActiveRecord::Base

  ## MODULES
  include ShopifyApp::ShopSessionStorageWithScopes

  ## VALIDATIONS
  validates :usage_limit_update_amount, numericality: { greater_than: 0 }
  validates :usage_limit_update_amount_for_exhausted, numericality: { greater_than: 0 }

  ## ASSOCIATIONS
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :codes, dependent: :destroy
  has_many :prefixes, dependent: :destroy
  has_many :settings, dependent: :destroy
  has_many :promo_code_generated_records, dependent: :destroy

  ## SCOPES
  scope :automate_usage_limit_update, -> { where(automate_usage_limit_update: true) }

  ## CALLBACKS
  after_commit :add_shopify_email, on: :create
  after_commit :enqueue_fetch_all_shopify_products_job, on: :create

  ## CLASS METHODS
  def self.enqueue_code_usage_limit_update_job
    CodeUsageLimitUpdateJob.perform_later
  end

  ## INSTANCE METHODS
  def api_version
    ShopifyApp.configuration.api_version
  end

  def enqueue_fetch_all_shopify_products_job
    FetchAllShopifyProductsJob.perform_later(id)
  end

  def enqueue_modify_theme_job
    ModifyThemeJob.perform_later(id)
  end

  def pretty_errors
    errors.full_messages.join(';')
  end

  def update_shopify_details(updated_data)
    update(shopify_email: updated_data[:email], name: updated_data[:name])
  end

  def modify_theme
    if theme_already_modified? == 'no'
      add_files_to_theme
    end
  end

  def create_code_pages
    @existing_code_pages_handles = nil
    begin
      with_shopify_session do
        unless code_page_already_exists?
          CODE_PAGES_ATTRIBUTE_VALUES.each do |attributes|
            ShopifyAPI::Page.create(title: attributes[:title], handle: attributes[:handle], template_suffix: attributes[:template_suffix])
          end
          return true
        else
          existing_code_pages_handles = @existing_code_pages.collect{ |code_page| code_page.handle }
          errors.add(:base, :code_page_already_exist, count: existing_code_pages_handles.length, handles: existing_code_pages_handles.to_sentence)
          return false
        end
      end
    rescue Exception => exception
      Bugsnag.notify(exception)
      errors.add(:base, exception.message)
      return false
    end
  end

  def store_link(path_link, query_hash=nil)
    link = "https://#{shopify_domain}" + path_link
    link += "?#{query_hash.to_query}" if query_hash
    link
  end

  private def add_shopify_email
    begin
      with_shopify_session do
        update_columns(shopify_email: ShopifyAPI::Shop.current.email, name: ShopifyAPI::Shop.current.name)
      end
    rescue Exception => exception
      Bugsnag.notify(exception);
    end
  end

  private def theme_already_modified?
    # return:-
    # 'yes' if even one file exists
    # 'no' if none of the file exists
    # 'job fail' if job fails
    begin
      with_shopify_session do |variable|
        existing_files = ShopifyAPI::Asset.all.select{ |asset| SHOPIFY_FILES_PATHS.values.include?(asset.key) }
        if existing_files.any?
          if existing_files.length == SHOPIFY_FILES_PATHS.length
            send_theme_already_modifed_email
          else
            send_theme_already_partially_modifed_email
          end
          return 'yes'
        else
          return 'no'
        end
      end
    rescue Exception => exception
      Bugsnag.notify(exception)
      send_theme_modification_failure_email
      return 'job_failed'
    end
  end

  private def add_files_to_theme
    SHOPIFY_FILES_PATHS.each do |key, path|
      file_value = get_file_value(key)
      begin
        with_shopify_session do
          ShopifyAPI::Asset.create(key: path, value: file_value)
        end
      rescue Exception => exception
        Bugsnag.notify(exception)
        send_theme_modification_failure_email
        return
      end
    end
    send_theme_modification_success_email
  end

  private def code_page_already_exists?
    code_pages_handles = CODE_PAGES_ATTRIBUTE_VALUES.collect { |code_page_attributes| code_page_attributes[:handle] }
    @existing_code_pages = ShopifyAPI::Page.all.select{ |page| code_pages_handles.include?(page.handle) }
    if @existing_code_pages.any?
      return true
    end
    return false
  end

  private def get_file_value(key)
    data = IO.read(APP_FILE_PATHS[key])
  end

  private def send_theme_already_modifed_email
    ThemeMailer.theme_already_modified_email(id).deliver_later
  end

  private def send_theme_already_partially_modifed_email
    ThemeMailer.theme_already_partially_modified_email(id).deliver_later
  end

  private def send_theme_modification_failure_email
    ThemeMailer.theme_modification_failure_email(id).deliver_later
  end

  private def send_theme_modification_success_email
    ThemeMailer.theme_modification_success_email(id).deliver_later
  end

end
