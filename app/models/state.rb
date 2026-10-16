class State < ApplicationRecord

  ## VALIDATIONS
  validates :name, :code, presence: true
  validates :name, uniqueness: { scope: [:code, :country] }

  ## ASSOCIATIONS
  belongs_to :country

end
