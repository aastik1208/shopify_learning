class Country < ApplicationRecord

  ## CONSTANTS
  DOMESTIC_COUNTRY_CODES = [:US]

  ## VALIDATIONS
  validates :name, :code, presence: true
  validates :name, uniqueness: { scope: :code }

  ## ASSOCIATIONS
  has_many :states, dependent: :destroy
  has_many :orders
  accepts_nested_attributes_for :states

  ## SCOPES
  scope :default, -> { where(code: DOMESTIC_COUNTRY_CODES) }
  scope :domestic, -> { where(code: DOMESTIC_COUNTRY_CODES) }
  scope :international, -> { where.not(code: DOMESTIC_COUNTRY_CODES) }

  ## INSTANCE METHODS
  def domestic?
    DOMESTIC_COUNTRY_CODES.any? { |domestic_code| domestic_code == code.to_sym }
  end

end
