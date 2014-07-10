class SetPrimaryCurrencyOperatorPriceToClaims < ActiveRecord::Migration
  def up
    ThinkingSphinx.deltas_enabled = false
    #logger = Logger.new('log/migration_correct__in_claims.log')

    Claim.where('operator_price > 0').find_each(:batch_size => 500) do |claim|
     # logger.info "#{claim.id}: phone#{claim.operator_price}isn't valid"
      case claim.operator_price_currency
      when 'eur'
        curr = claim.course_eur
      when 'usd'
        curr = claim.course_usd
      else
        curr = 1
      end
      if curr
        primary_currency_operator_price = claim.operator_price.to_f * curr
        claim.update_column(:primary_currency_operator_price, primary_currency_operator_price)
      end
    end
  end

  def down
  end
end
