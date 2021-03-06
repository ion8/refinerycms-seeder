require 'refinery/seeds/dsl/methods'
require 'refinery/seeds/images'
require 'refinery/seeds/page_builder'
require 'refinery/seeds/page_part_builder'


module Refinery::Seeds
  class DSL

    attr_reader :images

    class << self
      def evaluate(&block)
        new(RootMethods).evaluate(&block)
      end
    end

    def initialize(methods, builder = nil)
      extend methods
      define_singleton_method(:builder) { builder }
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

  end
end
