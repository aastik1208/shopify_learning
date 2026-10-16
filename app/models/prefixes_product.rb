class PrefixesProduct < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :product
  belongs_to :prefix

  ## CALLBACKS
  after_destroy :destroy_associated_prefix

  private def destroy_associated_prefix
    if prefix.products.size == 1 && prefix.codes.size == 0
      prefix.destroy
    end
  end

end
