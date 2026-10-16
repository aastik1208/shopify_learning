class AdminMailer < ApplicationMailer

  def send_promo_codes_report_email(prefix_id, usage_type, email)
    send_report_mail(prefix_id, usage_type, email)
  end

  private def send_report_mail(prefix_id, usage_type, email)
    @prefix = Prefix.find_by(id: prefix_id)
    @shop = @prefix.shop

    codes = @prefix.codes
    case usage_type
    when 0
      codes = codes.used
    when 1
      codes = codes.unused
    end

    @report_data = codes.to_csv
    attachment_name = "#{@shop.name} webstore - Prefix #{@prefix.name} Code Report.csv"
    attachments[attachment_name] = {
      mime_type: "text/csv",
      content: @report_data
    }

    mail(to: email, subject: t('.subject', shop_name: @shop.name))
  end
end
