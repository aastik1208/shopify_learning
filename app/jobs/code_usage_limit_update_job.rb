class CodeUsageLimitUpdateJob < ApplicationJob

  def perform
    Shop.automate_usage_limit_update.each do |shop|
      update_amount = shop.usage_limit_update_amount
      shop.codes.each do |code|
        used_value = code.times_used
        if used_value > 0 && used_value + update_amount > code.usage_limit
          code.update(usage_limit: used_value + update_amount)
        end
      end
    end
    # TDO
  end

end
