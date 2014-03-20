module Refinery
  module Seeder
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
          image_loader = Images::ImageLoader.new
          @images = image_loader.load_images
        end
      end

      module PageMethods
        include DynamicWriterMethods

        def page; builder end

        def part(title, attributes = {})
          part_builder = PagePartBuilder.new(title, attributes)
          part_builder.build
        end
      end

    end
  end
end
