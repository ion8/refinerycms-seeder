require 'refinery/pages'


module Refinery
  module Seeder
    class PageBuilder
      attr_accessor :attributes, :title, :page, :part_builders

      def initialize(title, attributes = {})
        @title = title
        @attributes = attributes.merge(title: title)
        @part_builders = []
        @kept_part_titles = []
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

      def keep_part(part_title)
        @kept_part_titles << part_title
      end

      def clean_parts!
        if @page.nil?
          false
        else
          parts_to_destroy = @page.parts.reject do |part|
            @kept_part_titles.map(&:downcase).include?(part.title.downcase)
          end
          parts_to_destroy.each(&:destroy)
          parts_to_destroy.length
        end
      end
    end
  end
end
