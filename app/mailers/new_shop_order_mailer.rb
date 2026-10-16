class NewShopOrderMailer < ApplicationMailer

  def send_order_email_to_admin(shop_id, params, variant_ids, product_ids)
    @shop = Shop.find_by(id: shop_id)
    @product_ids, @products = product_info(product_ids)
    @variant_ids = variant_ids
    @order = params
    Rails.logger.info("inside Mailer: order_params: #{params} \n variant_ids: #{variant_ids} \n product_ids: #{product_ids}")
    Rails.logger.info("products: #{@products} \n 
    				         product_ids: #{@product_ids}")
    Code.find_by_id(params['code_id']).used
    mail(to: @shop.shopify_email, subject: "New Order Requested")
  
  end

  def product_info(product_ids)
    if product_ids.present?
      ids = product_ids.reject { |item| item.blank? }
      product_names = ids.map{|x| Product.find_by_id(x).shopify_title}.join(",")
    else
      product_names = nil
    end  
    [product_ids, product_names]
  end

end
