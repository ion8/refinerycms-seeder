module Refinery::Seeds
  class DSL

    module DynamicWriterMethods
      def set(attribute, value)
        builder.set(attribute, value)
      end

      def method_missing(meth, *args, &block)
        builder.writable?(meth) ? set(meth, *args) : super
      end

      def respond_to?(meth)
        builder.writable?(meth) || super
      end
    end

    module RootMethods
      def page(title, attributes = {}, &block)
        page_builder = PageBuilder.new(title, attributes)
        DSL.new(PageMethods, page_builder).evaluate(&block)
        page_builder.build
      end

      def load_images
        Images::ImageLoader.load_images
      end
    end

    module PageMethods
      include DynamicWriterMethods

      def page; builder end

      def part(title, attributes = {})
        page.add_part PagePartBuilder.new(page, title, attributes)
      end

      def keep_part(part_title)
        builder.keep_part part_title
      end

      def clean_parts!
        builder.will_clean_parts = true
      end
    end

  end
end
