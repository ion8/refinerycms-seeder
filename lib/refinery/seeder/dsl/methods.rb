module Refinery
  module Seeder
    class DSL

      module DynamicWriterMethods
        def set(attribute, value)
          page.send("#{attribute}=", value)
        end

        def method_missing(meth, *args, &block)
          writable?(meth) ? set(meth, *args) : super
        end

        def respond_to?(meth)
          instance.respond_to?("#{meth}=") || super
        end

        private
        def writable?(attribute)
          instance.respond_to? "#{attribute}="
        end
      end

      module RootMethods
        def page(title, attributes = {}, &block)
          page = PageBuilder.new(title, attributes)
          DSL.new(PageMethods, page).evaluate(&block)
          page.build
        end
      end

      module PageMethods
        include DynamicWriterMethods

        def page; instance end

        def part(title, attributes = {})
          part = PagePartBuilder.new(title, attributes)
          if block_given?
            DSL.new(PagePartMethods, part).evaluate(&block)
          end
          part.build
        end
      end

      module PagePartMethods
        include DynamicWriterMethods

        def part; instance end
      end

    end
  end
end
