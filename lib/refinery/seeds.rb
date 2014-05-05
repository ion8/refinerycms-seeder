require 'refinery/seeds/version'


module Refinery
  module Seeds
    autoload :PageBuilder,      'refinery/seeds/page_builder'
    autoload :PagePartBuilder,  'refinery/seeds/page_part_builder'
    autoload :PageImagesBuilder,'refinery/seeds/page_images_builder'
    autoload :Images,           'refinery/seeds/images'
    autoload :DSL,              'refinery/seeds/dsl'

    class << self
      def seed(&block)
        DSL.evaluate(&block)
      end

      def resources_root
        @@resources_root
      end

      def resources_root=(root)
        @@resources_root = root
      end

      @@resources_root = File.expand_path(
        File.join('app', 'seeds'),
        defined?(Rails) ? Rails.root : '.'
      )
    end
  end
end
