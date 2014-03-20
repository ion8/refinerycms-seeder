require 'refinery/pages'


module Refinery
  module Seeder
    class PageBuilder
      attr_accessor :attributes, :title

      def initialize(title, attributes = {})
        @title = title
        @attributes = attributes.merge(title: title)
      end

      def writable?(attribute)
        return false if attribute.to_s == 'title'
        Refinery::Page.accessible_attributes.include? attribute
      end

      def set(attribute, value)
        if writable? attribute
          @attributes[attribute] = value
        else
          raise ArgumentError, "Can't write #{attribute} attribute"
        end
      end

      def build
        page = Refinery::Page.by_title(@title)

        if page.nil?
          page = Refinery::Page.create!(@attributes)
        else
          page.update!(@attributes)
        end

        page
      end
    end
  end
end
