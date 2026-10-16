class Prefix < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :shop
  has_many :prefixes_product
  has_many :products, through: :prefixes_product, dependent: :destroy
  has_many :codes, dependent: :destroy

  ## VALIDATIONS
  validates :name, presence: true, length: { is: 3, allow_blank: true }, uniqueness: { scope: :shop, allow_blank: true }
  validates :name, allow_blank: true, format: {
    with: PREFIX_NAME_REGEX
  }

  ## SCOPES
  scope :collection_handle_not_set, -> { where(custom_collection_handle: nil) }

  ## CALLBACKS
  after_commit :enqueue_collection_creation_job, on: :create, if: -> { custom_collection_handle.nil? }

  def enqueue_collection_creation_job
    CreateCustomCollectionForPrefixJob.perform_later(id)
  end

  def send_promo_codes_usage_report(usage_type, email)
    AdminMailer.send_promo_codes_report_email(id, usage_type, email).deliver_later
  end

end
