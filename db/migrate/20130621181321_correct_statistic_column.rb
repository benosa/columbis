class CorrectStatisticColumn < ActiveRecord::Migration

  def up
    values = [
      {name: I18n.t('intervals.channels.internet'), like_as: ["интернет", "инет", "инэт", "интернэт", "интэрнэт", "веб", "вэб"], stat: 0, old: []},
      {name: I18n.t('intervals.channels.recommendations'), like_as: ["рекоменд", "агент", "агенcт", "компания", "ооо", "оао"], stat: 0, old: []},
      {name: I18n.t('intervals.channels.client'), like_as: ["клиент", "жена", "брат", "отец", "мать", "бабушка", "дед", "дедушка", "сестр", "муж", "подруга", "друг", "подруж", "родствен", "знаком", "друзья", "родите"], stat: 0, old: []},
      {name: I18n.t('intervals.channels.magazines'), like_as: ["журнал", "газет"], stat: 0, old: []},
      {name: I18n.t('intervals.channels.signboard'), like_as: ["вывеск", "брошюр", "листовк", "сам"], stat: 0, old: []},
      {name: I18n.t('intervals.channels.tv'), like_as: ["телевизор", "тв", "реклам"], stat: 0, old: []},
      {name: I18n.t('intervals.channels.default'), like_as: ["-"], stat: 0, old: []}
    ]

    logger = Logger.new('log/migrate_correct_statistic.log')
    logger.info(){"#{Time.zone.now}. Begin grouping all incorect statistic"}

    Claim.select([:id, :tourist_stat]).find_each(:batch_size => 500) do |claim|

      old_value = claim.tourist_stat

      values.each do |value|
        if  value[:name] == values[6][:name] ||
            value[:like_as].any?{|x| claim.tourist_stat.mb_chars.downcase[/#{x}/] != nil }
          if claim.update_column(:tourist_stat, value[:name])
            logger.info() {"correct #{claim.id}: #{old_value} => #{value[:name]}"}
            value[:stat] += 1
            value[:old] << old_value
            value[:old] = value[:old].uniq
          else
            logger.error() {"correct #{claim.id}: #{claim.errors.full_messages}"}
          end
          break
        end
      end

    end

    values.each do |value|
      logger.info() {"Replace to #{value[:name]} #{value[:stat]} times. Old values:\n#{value[:old].to_s}"}
    end

    DropdownValue.where(:list => "tourist_stat").delete_all

    logger.close
  end

  def down
  end
end
