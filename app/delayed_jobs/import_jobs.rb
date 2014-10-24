# Custom delayed jobs for import
# Импорт производится из xls файла в стандартной кодировке (не xml)
# Сейчас включен импорт только потенциальный клиентов на первом листе в формате
# ФИО, Телефон(+7...), Email, Пожелания со второй строки
module ImportJobs

  def self.import_file(import_info_id)
    Delayed::Job.enqueue ImportFile.new(import_info_id)
  end

  class ImportFile < Struct.new(:import_info_id)
    def perform
      # Original values of configuration parameters
      origin_config_values = {
        deltas_enabled: ThinkingSphinx.deltas_enabled?,
        support_delivery: CONFIG[:support_delivery]
      }
      ThinkingSphinx.deltas_enabled = false # Suppress delta indexing of thinking sphinx
      CONFIG[:support_delivery] = false # Turn off email sendings

      import_info = ImportInfo.find(import_info_id)
      if import_info.filename?
        importing = Import::Formats::XLS.new([:client_simple], import_info.filename.path, import_info.company_id, import_info.id)
      #  importing = Import::Formats::XLS.new([:client, :operator, :tourist, :claim, :payment_operator, :payment_tourist], import_info.filename.path, import_info.company_id, import_info.id)

        result = importing.start
        if result[:success]
          # claim_ids = ImportItem.select(:model_id).where(model_class: 'Claim', import_info_id: import_info_id).all.map { |c| c.model_id }
          # if claim_ids.count
          #   Claim.where(id: claim_ids).each do |cl|
          #     cl.save
          #   end
          # end
          count = ImportItem.where(import_info_id: import_info_id).count
          success_count = ImportItem.where(import_info_id: import_info_id, success: true).count
          ImportInfo.update(import_info_id, status: 'success', count: count, success_count: success_count)
        else
          ImportInfo.update(import_info_id, status: 'failed', data: result[:data].to_yaml)
        end
      else
        ImportInfo.update(import_info_id, status: 'failed')
      end

      ThinkingSphinx.deltas_enabled = origin_config_values[:deltas_enabled]
      CONFIG[:support_delivery] = origin_config_values[:support_delivery]
      Rake::Task["thinking_sphinx:reindex"].invoke
    end
  end
end