module Refinery
  module Seeder
    autoload :PageBuilder,      'refinery/seeder/page_builder'
    autoload :PagePartBuilder,  'refinery/seeder/page_part_builder'
    autoload :DSL,              'refinery/seeder/dsl'
    autoload :VERSION,          'refinery/seeder/version'

    class << self
      def resources_root
        @@resources_root
      end

      def resources_root=(root)
        @@resources_root = root
      end

      @@resources_root = File.expand_path(
        File.join('lib', 'seeds'),
        defined?(Rails) ? Rails.root : '.'
      )
    end
  end
end
