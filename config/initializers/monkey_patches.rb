class Float
  def to_money
    sprintf("%0.0f", self)
  end

  def to_percent
    sprintf("%0.2f", self)
  end

  def amount_in_word(currency)
    str = RuPropisju.amount_in_words(self, currency)
    str.capitalize.to_s # str.mb_chars.capitalize.to_s
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