class RandomPromoCodeGenerator

  attr_reader :shop, :prefix, :setting, :code_params, :promo_code_generated_record

  def initialize(record, shop, setting, code_params)
    @promo_code_generated_record = record
    @shop = shop
    @prefix = code_params[:prefix]
    @setting = setting
    @code_params = code_params
  end

  def generate_codes
    count = code_params[:count].to_i
    created = []
    while created.size < count
      code_name = SecureRandom.alphanumeric(8).upcase()
      created_code, invalid_names, duplicate_names = create_code(code_params, code_name)
      created << created_code.first unless created_code.first.nil?
    end

    if code_params[:add_complete_url_column] == '1'
      csv_file = generate_csv_with_url(created)
    else
      csv_file = generate_csv(created)
    end

    promo_code_generated_record.update(prefix: prefix, count: count)
    promo_code_generated_record.attach_generated_codes_csv(csv_file)
  end

  def promo_code_prefix_valid?
    prefix.length == 3 && prefix =~ PREFIX_NAME_REGEX
  end

  def create_code(promo_code_params, code_name)
    create_params = promo_code_params.merge(names: attach_prefix_to_codes(code_name))
    setting.create_promo_codes(create_params)
  end

  def attach_prefix_to_codes(name)
    name.prepend(prefix + '-')
  end

  def generate_csv(codes)
    attributes = %w{name products_in_order_limit usage_limit expiry_date}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      codes.each do |code|
        csv << code.attributes.values_at(*attributes)
      end
    end
  end

  def generate_csv_with_url(codes)
    attributes = %w{name products_in_order_limit usage_limit expiry_date}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      codes.each do |code|
        attrs = code.attributes.values_at(*attributes)
        attrs << shop.store_link(STORE_PAGES[:products], { code: code.name })
        csv << attrs
      end
    end
  end

end
