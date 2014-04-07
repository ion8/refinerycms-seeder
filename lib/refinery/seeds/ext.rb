module Refinery::Seeds
  module StringExtensions
    def underscored_word
      ::I18n.transliterate(self).
      gsub(/([a-z])([A-Z])/, '\1_\2').
      gsub(/([A-Z])([A-Z][a-z])/, '\1_\2').
      gsub(/\s+/, '_').
      gsub(/-+/, '_').
      downcase
    end
  end
end

String.send :include, Refinery::Seeds::StringExtensions
