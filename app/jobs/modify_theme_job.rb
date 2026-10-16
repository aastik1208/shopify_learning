class ModifyThemeJob < ApplicationJob

  def perform(shop_id)
    shop = Shop.find_by(id: shop_id)
    shop.modify_theme if shop.present?
  end

end
