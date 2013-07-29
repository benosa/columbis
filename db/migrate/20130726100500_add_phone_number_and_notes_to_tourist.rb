class AddPhoneNumberAndNotesToTourist < ActiveRecord::Migration
  def up
    add_column :tourists, :note, :text
    
    Tourist.reset_column_information
    
    phones = Tourist.where('length(phone_number) notnull')
    phones.each do |phone|
      phone.update_attributes({ note: phone.phone_number, phone_number: nil })
    end

    notes = Tourist.where('length(note) > 8')
    notes.each do |note|
      puts "======> #{note.note}"
      normal_phone = normalize_phone(note.note)
      puts "normal phone: #{normal_phone}"
      if normal_phone.length == 10
        a = note.update_attributes({ phone_number: normal_phone, note: nil })
        puts a.to_yaml
      end
      
    end
  end
  
  def down
    remove_column :tourists, :note
  end
  
  def normalize_phone number
    unless number.gsub(/^[8,7]/,'').nil?
      a = number.gsub!(/\D/, '') || number
      a = a.gsub(/^[8,7]/,'')
    end
  end
end
