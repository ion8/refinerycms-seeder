require 'refinery/seeder/dsl/methods'
require 'refinery/seeder/images'
require 'refinery/seeder/page_builder'
require 'refinery/seeder/page_part_builder'


module Refinery
  module Seeder
    class DSL

      attr_reader :images

      class << self
        def evaluate(&block)
          new(RootMethods).evaluate(&block)
        end
      end

      def initialize(methods, instance = nil)
        extend methods
        define_singleton_method(:instance) { instance }
        @images = {}
      end

      def evaluate(&block)
        @block_self = eval("self", block.binding)
        @block = block
        instance_eval(&@block)
      end

      def method_missing(method, *args, &block)
        @block_self.send(method, *args, &block)
      end

      def load_images
        image_loader = Images::ImageLoader.new
        @images = image_loader.load_images
      end

    end
  end
end
