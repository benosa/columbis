class FixingHotelStars < ActiveRecord::Migration
  def up
    bads = []

    logger = Logger.new('log/migrate_correct_hotel_stars.log')
    logger.info(){"#{Time.zone.now}. Begin editing all incorect hotel stars"}

    Claim.select([:id, :hotel]).find_each(:batch_size => 500) do |claim|

      hotel = Change.new(claim.hotel)
      case hotel.status
      when :renamed
        claim.update_column(:hotel, hotel.new_name)
        DropdownValue.where(:list => "hotel").where(:value => hotel.old_name).update_all(:value => hotel.new_name)
        logger.info() {"Rename: #{hotel.old_name} => #{hotel.new_name}"}
      when :bad
        bads << hotel
        logger.info() {"Don't renamed: #{hotel.old_name}"}
      when :good
        logger.info() {"No need to change: #{hotel.old_name}"}
      end

    end

    if bads.length != 0
      logger.info() {"|||||||||||||=====List of did not renamed hotels:"}
      bads.each_with_index{|bad, i| logger.info() {"#{i}. #{bad.old_name}"} }
    end

    logger.close
  end

  def down
  end

  private

    class Change
      attr_accessor :old_name, :new_name, :status
      def initialize(name)
        @old_name = name
        if (/(\s[1-5]\*)\Z/ =~ name).nil?
          if (/[1-5]\*/ =~ name).nil?
            if (/([^0-9][1-5])\Z/ =~ name).nil?
              @new_name = nil #no template
              @status = :bad
            else
              z = (/([^0-9][1-5])\Z/.match name).to_s #template: "ashdk1"
              z = "#{z[1]}*"
              @new_name = name.gsub(/([^0-9][1-5])\Z/, '')
              @new_name = "#{@new_name} #{z}"
              @status = :renamed
            end
          else
            z = (/[1-5]\*/.match name).to_s #template: "asd1*dasd"
            @new_name = name.gsub(/[1-5]\*/, '')
            @new_name = "#{@new_name} #{z}"
            @status = :renamed
          end
        else
          @new_name = name #template: "ASddsd 4*"
          @status = :good
        end
      end
    end
end