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
          @attributes.each do |name, value|
            page.send("#{name}=", value)
          end
          page.save!
        end
      end
    end
  end
end
