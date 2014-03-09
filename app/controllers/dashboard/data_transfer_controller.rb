class Dashboard::DataTransferController < ApplicationController

  before_filter { raise CanCan::AccessDenied unless is_admin? or is_boss? }

  def index
    @import_list = ImportInfo.where(company_id: current_company.id).order('num desc').all
    @import_list.each do |lv|
      data_str = ''
      if lv.data
        data_a = YAML.load lv.data
        if data_a.kind_of?(Hash)
          data_a.each do |k,v|
            data_str += t("dashboard.transfer.#{k}") + " #{v}; "
          end
          lv.data = data_str
        end
      end
    end

    path = Rails.root.join "uploads/#{current_company.id}/export.xls"
    if File.exist?(path)
      @furl = root_path + "uploads/#{current_company.id}/export.xls"
      @ftime = File.mtime(path)
    end

    @import_info = ImportInfo.new
    render :index
  end

  def export
   # ExportJobs.import_file(current_company.id)

    respond_to do |format|
      format.xls {
        unless ExportJobs.working? current_company.id
          ExportJobs.export_file current_company.id
          redirect_to dashboard_data_index_path, :notice => t("dashboard.transfer.export_start")
        else
          redirect_to dashboard_data_index_path, :alert => t("dashboard.transfer.export_working")
        end
      }
    end
  end

  def check_export
    respond_to do |format|
      format.json do
        render json: { working: ExportJobs.working?(current_company.id) }.to_json
      end
      format.html do
        unless ExportJobs.working? current_company.id
          redirect_to dashboard_data_index_path, :notice => t("dashboard.transfer.export_done")
        else
          redirect_to dashboard_data_index_path, :alert => t("dashboard.transfer.export_working")
        end
      end
    end
  end

  def import
    if params[:import_info] && params[:import_info][:filename]
      @import_info = ImportInfo.create(status: 'new')
      @import_info.company = current_company
      @import_info.filename = params[:import_info][:filename]
      @import_info.save
      @import_info.perform
      redirect_to dashboard_data_index_path, :notice => t("dashboard.transfer.import_start")
    else
      redirect_to dashboard_data_index_path, :alert => t("dashboard.transfer.select_file")
    end
  end

end
