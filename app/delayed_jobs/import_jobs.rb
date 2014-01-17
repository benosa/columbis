# Custom delayed jobs for import
module ImportJobs

  def self.import_file(import_info_id)
    Delayed::Job.enqueue ImportFile.new(import_info_id)
  end

  class ImportFile < Struct.new(:import_info_id)
    def perform
      import_info = ImportInfo.find(import_info_id)
      if import_info.filename?
         ImportInfo.update(import_info_id, status: 'olo3')
        importing = Import::Formats::XLS.new([:client, :operator, :tourist, :claim, :payment_operator, :payment_tourist], import_info.filename.path, import_info.company_id, import_info.id)
  #  importing = Import::Formats::XLS.new([:claim], filename, current_company.id, import_new.id)
        importing.start

        claim_ids = ImportItem.select(:model_id).where(model_class: 'Claim', import_info_id: import_info_id).all.map { |c| c.model_id }
        if claim_ids.count
          Claim.find(claim_ids).each do |cl|
            cl.save
          end
        end
      else
        ImportInfo.update(import_info_id, status: 'neolo')
      end
    end
  end
end