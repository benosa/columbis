# Custom delayed jobs for import
module ImportJobs

  def self.import_file(import_info_id)
    Delayed::Job.enqueue ImportFile.new(import_info_id)
  end

  class ImportFile < Struct.new(:import_info_id)
    def perform
      import_info = ImportInfo.find(import_info_id)
      if import_info.filename?
        importing = Import::Formats::XLS.new([:client, :operator, :tourist, :claim, :payment_operator, :payment_tourist], import_info.filename.path, import_info.company_id, import_info.id)
#        importing = Import::Formats::XLS.new([:claim, :payment_operator, :payment_tourist], import_info.filename.path, import_info.company_id, import_info.id)

        result = importing.start
        if result[:success]
          claim_ids = ImportItem.select(:model_id).where(model_class: 'Claim', import_info_id: import_info_id).all.map { |c| c.model_id }
          if claim_ids.count
            Claim.find(claim_ids).each do |cl|
              cl.save
            end
          end
          count = ImportItem.where(import_info_id: import_info_id).count
          success_count = ImportItem.where(import_info_id: import_info_id, success: true).count
          ImportInfo.update(import_info_id, status: 'success', count: count, success_count: success_count)
        else
          ImportInfo.update(import_info_id, status: 'failed', data: result[:data].to_yaml)
        end
      else
        ImportInfo.update(import_info_id, status: 'failed')
      end
    end
  end
end