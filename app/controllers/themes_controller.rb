class ThemesController < AuthenticatedController

  skip_before_action :verify_authenticity_token, if: :jwt_shopify_domain
  skip_before_action :redirect_to_splash_page, only: :download_file
  before_action :get_theme_file_path, only: [:download_file]


  def modification_instructions
  end

  def download_file
    send_data IO.read(@file_path), filename: SHOPIFY_FILES_PATHS[params[:file_path_key].to_sym].split('/')[1]
  end

  def modify
    current_shop.enqueue_modify_theme_job
    flash[:notice] = t('.theme_modification_job_enqueued')
    redirect_to modification_instructions_themes_path
  end

  def create_code_pages
    if current_shop.create_code_pages
      flash[:notice] = t('.code_pages_successfully_created')
    else
      flash[:error] = current_shop.pretty_errors
    end
    redirect_to modification_instructions_themes_path
  end

  private def get_theme_file_path
    @file_path = APP_FILE_PATHS[params[:file_path_key].to_sym]
  end

end
