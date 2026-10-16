class ReportsController < AuthenticatedController

  skip_before_action :verify_authenticity_token, if: :jwt_shopify_domain
  before_action :ensure_prefix_exists, only: :index
  before_action :load_prefix, only: :create

  def index
  end

  def create
    if report_params[:email].present?
      @prefix.send_promo_codes_usage_report(report_params[:code_usage_type].to_i, report_params[:email])
    end
    redirect_to reports_path, notice: t('.mail_sent')
  end

  private def ensure_prefix_exists
    unless current_shop.prefixes.exists?
      redirect_to home_path, notice: t('.no_prefixes')
    end
  end

  private def load_prefix
    @prefix = current_shop.prefixes.find_by(name: report_params[:prefix])
    unless @prefix.present?
      redirect_to home_path, alert: t('.invalid_prefix') and return
    end
  end

  private def report_params
    params.permit(:prefix, :code_usage_type, :email)
  end
end
