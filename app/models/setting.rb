class Setting < ApplicationRecord

  ## VALIDATIONS
  validates :has_free_domestic_shipping, :has_free_international_shipping, :allow_domestic_shipping, :allow_international_shipping, inclusion: [true, false]
  validate :atleast_one_shipping_is_selected
  validates :allow_domestic_shipping, inclusion: [true], if: :has_free_domestic_shipping
  validates :allow_international_shipping, inclusion: [true], if: :has_free_international_shipping

  ## ASSOCIATIONS
  has_many :codes, dependent: :restrict_with_error
  belongs_to :shop

  ## INSTANCE METHODS
  def create_promo_codes(params)
    names = params[:names].strip.upcase.split(/[\s\n,]+/).uniq
    created, duplicate_names, invalid_names = [], [], []

    ActiveRecord::Base.transaction do
      names.each do |name|
        ## checking for duplicate code
        if shop.codes.find_by(name: name).present?
          duplicate_names << name
        else
          new_code = codes.create(name: name,
                                 products_in_order_limit: params[:products_in_order_limit],
                                 usage_limit: params[:usage_limit],
                                 expiry_date: params[:expiry_date],
                                 shop: shop
                                )
          if new_code.persisted?
            created << new_code
          else
            invalid_names << new_code.name
            codes.reload
          end
        end
      end
    end

    return created, invalid_names, duplicate_names
  end

  def free_shipping_for
    if has_free_international_shipping? && has_free_domestic_shipping?
      return 'all'
    elsif has_free_domestic_shipping?
      return 'domestic'
    elsif has_free_international_shipping?
      return 'international'
    end
    return 'none'
  end

  private def atleast_one_shipping_is_selected
    if allow_domestic_shipping.blank? && allow_international_shipping.blank?
      errors.add(:base, :select_atleast_one_shipping)
    end
  end

end
