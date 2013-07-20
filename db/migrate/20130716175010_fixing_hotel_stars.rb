class FixingHotelStars < ActiveRecord::Migration
  def up
    bads = []

    logger = Logger.new('log/migrate_correct_hotel_stars.log')
    logger.info(){"#{Time.zone.now}. Begin editing all incorect hotel stars"}

    Claim.select([:id, :hotel]).find_each(:batch_size => 500) do |claim|

      hotel = Change.new(claim.hotel, claim.id)
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
      require 'csv'
      CSV.open('log/hotels_without_stars.csv', 'w+') do |writer|
        writer << ["No", "Name", "New name"]
        bads.each_with_index do |bad, i|
          writer << [bad.claim_id, bad.old_name, '']
        end
      end
    end

    logger.close
  end

  def down
  end

  private

    class Change
      attr_accessor :old_name, :new_name, :status, :claim_id
      def initialize(name, id)
        @claim_id = id
        @old_name = name
        if     !(TEMPLATES["aaaa 1*"][:filter] =~ name).nil?
          @new_name = name
          @status = TEMPLATES["aaaa 1*"][:status]

        elsif !(TEMPLATES["aa1*aa"][:filter] =~ name).nil?
          z = (TEMPLATES["aa1*aa"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aa1*aa"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aa1*aa"][:status]

        elsif !(TEMPLATES["aaaa1"][:filter] =~ name).nil?
          z = (TEMPLATES["aaaa1"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aaaa1"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aaaa1"][:status]

        elsif !(TEMPLATES["aaaa1+"][:filter] =~ name).nil?
          z = (TEMPLATES["aaaa1+"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aaaa1+"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aaaa1+"][:status]

        elsif !(TEMPLATES["aaaa1 +"][:filter] =~ name).nil?
          z = (TEMPLATES["aaaa1 +"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aaaa1 +"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aaaa1 +"][:status]

        elsif !(TEMPLATES["aaaa1+*"][:filter] =~ name).nil?
          z = (TEMPLATES["aaaa1+*"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aaaa1+*"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aaaa1+*"][:status]

        elsif !(TEMPLATES["aaaa1*+"][:filter] =~ name).nil?
          z = (TEMPLATES["aaaa1*+"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aaaa1*+"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aaaa1*+"][:status]

        elsif !(TEMPLATES["aaaa1 *"][:filter] =~ name).nil?
          z = (TEMPLATES["aaaa1 *"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aaaa1 *"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aaaa1 *"][:status]

        elsif !(TEMPLATES["aaaa1+ *"][:filter] =~ name).nil?
          z = (TEMPLATES["aaaa1+ *"][:filter].match name).to_s[1]
          @new_name = name.gsub(TEMPLATES["aaaa1+ *"][:filter], '')
          @new_name = "#{@new_name} #{z}*"
          @status = TEMPLATES["aaaa1+ *"][:status]
        else
          @status = :bad
        end
      end

      private
        TEMPLATES =
          {
            "aaaa 1*" => { :filter => /(\s[1-5]\*)\Z/, :status => :good },
            "aa1*aa" => { :filter => /[^0-9][1-5]\*/, :status => :renamed },
            "aaaa1" => { :filter => /([^0-9][1-5])\Z/, :status => :renamed },
            "aaaa1+" => { :filter => /([^0-9][1-5]\+)\Z/, :status => :renamed },
            "aaaa1 +" => { :filter => /([^0-9][1-5]\s\+)\Z/, :status => :renamed },
            "aaaa1+*" => { :filter => /([^0-9][1-5]\+\*)\Z/, :status => :renamed },
            "aaaa1*+" => { :filter => /([^0-9][1-5]\*\+)\Z/, :status => :renamed },
            "aaaa1 *" => { :filter => /([^0-9][1-5]\s\*)\Z/, :status => :renamed },
            "aaaa1+ *" => { :filter => /([^0-9][1-5]\+\s\*)\Z/, :status => :renamed }
          }
    end
end