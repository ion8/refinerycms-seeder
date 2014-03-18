require 'refinery/pages'

module Refinery
  module Seeder
    class PageBuilder
      attr_accessor :attributes, :title

      def initialize(title, attributes = {})
        @title = title
        @attributes = attributes.merge(title: title)
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
