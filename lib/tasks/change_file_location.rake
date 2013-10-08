namespace :change_file_location do
  task :move_files => :environment do
    Company.select(:id).map{ |company| company.id }.each do |id|
      from = Rails.root.join("public/uploads/printer/company_#{id}/template/.").to_s
      to = Rails.root.join("uploads/#{id}/printer/").to_s
      if Dir.exist?(from)
        FileUtils.mkdir_p to
        FileUtils.cp_r from, to
      end

      from = Rails.root.join("public/uploads/logo/company_#{id}/.").to_s
      to = Rails.root.join("uploads/#{id}/logo/").to_s
      if Dir.exist?(from)
        FileUtils.mkdir_p to
        FileUtils.cp_r from, to
      end
    end

    FileUtils.remove_dir("public/uploads")
  end
end