class CreateCustomCollectionForPrefixJob < ApplicationJob

  def perform(prefix_id)
    prefix = Prefix.find_by(id: prefix_id)
    if prefix.present? && !prefix.custom_collection_handle?
      shop = prefix.shop
      create_collection_on_shopify(prefix, shop)
    end
  end

  def create_collection_on_shopify(prefix, shop)
    begin
      shop.with_shopify_session do
        collection_title = PROMO_CODE_TAG_PREFIX.titlecase + ': ' + prefix.name
        collection_exists = ShopifyAPI::SmartCollection.find(:first, params: { handle: collection_title.parameterize })
        if collection_exists.present?
          prefix.update_columns(custom_collection_handle: collection_exists.handle)
        else
          @collection = ShopifyAPI::SmartCollection.new(
            title: collection_title,
            template_suffix: CUSTOM_COLLECTION[:template_suffix],
            rules: [
              { relation: CUSTOM_COLLECTION[:relation], column: CUSTOM_COLLECTION[:column], condition: collection_title }
            ]
          )
          @collection.save!
          prefix.update_columns(custom_collection_handle: @collection.handle)
        end
      end
    rescue Exception => exception
      if @collection.present? && @collection.errors.any?
        message = @collection.errors.full_messages.join(',')
      end
      Bugsnag.notify(message || exception)
    end
  end

end
