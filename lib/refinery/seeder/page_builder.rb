require 'refinery/pages'


module Refinery
  module Seeder
    class PageBuilder
      attr_accessor :attributes, :title, :page, :part_builders

      def initialize(title, attributes = {})
        @title = title
        @attributes = attributes.merge(title: title)
        @part_builders = []
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

      def add_part(part_builder)
        @part_builders << part_builder
      end

      def build
        page = Refinery::Page.by_title(@title).first

        if page.nil?
          page = Refinery::Page.create!(@attributes)
        else
          page.update_attributes!(@attributes)
        end

        @page = page
        build_parts
        @page
      end

      def build_parts
        @part_builders.each do |part_builder|
          part_builder.build(@page)
        end
      end
    end
  end
end
