class CreateSubdomainNames < ActiveRecord::Migration
  def up
    names = []
    Company.select([:id, :name]).find_each(:batch_size => 500) do |company|
      subdomain = Russian.translit(company.name).gsub(/[^\w]/,"")
      if company.name == "Мистраль"
        subdomain = "mistral"
      end
      if names.any? {|name| name == subdomain} || subdomain.blank?
        subdomain = subdomain.to_s + company.id.to_s
      else
        names << subdomain
      end
      company.update_column(:subdomain, subdomain.downcase)
    end
  end
end
