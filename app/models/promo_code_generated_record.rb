class PromoCodeGeneratedRecord < ApplicationRecord

  ## CONSTANTS
  PER_PAGE = 15

  ## ASSOCIATIONS
  belongs_to :shop
  has_one_attached :codes_file

  ## INSTANCE METHODS
  def attach_generated_codes_csv(csv_file)
    @temp_file = File.open("#{shop.name} - Generated Promo Codes.csv", 'a')
    @temp_file.write(csv_file)
    @temp_file.close
    @temp_file = File.open(@temp_file.path, 'r')
    codes_file.attach(io: @temp_file, filename: "#{shop.name} - Generated Promo Codes.csv", content_type: "text/csv")
    File.delete(@temp_file.path)
  end

  def create_promo_codes(code_params, setting)
    return if ensure_promo_code_prefix_exists(code_params)
    generator_service = RandomPromoCodeGenerator.new(self, shop, setting, code_params)

    if generator_service.promo_code_prefix_valid?
      generator_service.generate_codes
    else
      errors.add(:base, :prefix_invalid)
      return
    end
  end

  def ensure_promo_code_prefix_exists(code_params)
    if code_params[:prefix].blank?
      errors.add(:base, :prefix_required)
    end
  end

end
