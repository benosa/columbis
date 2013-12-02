# -*- encoding : utf-8 -*-
class Float
  def to_money
    sprintf("%0.0f", self)
  end

  def to_percent
    sprintf("%0.2f", self)
  end

  def amount_in_words(currency)
    begin
      str = RuPropisju.amount_in_words(self.abs, currency).mb_chars.capitalize.to_s
      str = '-' + str if self < 0
      str
    rescue
      ''
    end
  end

  def amount_in_word(currency)
    self.amount_in_words(currency)
  end
end

class Fixnum
  def amount_in_words(currency)
    begin
      str = RuPropisju.amount_in_words(self.abs, currency).mb_chars.capitalize.to_s
      str = '-' + str if self < 0
      str
    rescue
      ''
    end
  end
end

class BigDecimal
  def to_money
    sprintf("%0.0f", self)
  end

  def to_percent
    sprintf("%0.2f", self)
  end
end

class String
  def initial
    f = self.chars.first
    f ? "#{f}." : ""
  end
end

class Object
  def to_boolean
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean self
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      def localize(*args)
        #Avoid I18n::ArgumentError for nil values
        I18n.localize(*args) unless args.first.nil?
      end
      # l() still points at old definition
      alias l localize
    end
  end
end

module ActiveRecord
  class Base

    # return all records as array of hashes
    def self.all_hashes(arel, name = nil, binds = [])
      connection.select_all(arel, name, binds).each do |attrs|
        attrs.each_key do |attr|
          attrs[attr] = type_cast_attribute(attr, attrs)
        end
      end
    end

  end
end
