module Refinery
  module Seeder
    autoload :PageBuilder,      'refinery/seeder/page_builder'
    autoload :PagePartBuilder,  'refinery/seeder/page_part_builder'
    autoload :DSL,              'refinery/seeder/dsl'
    autoload :VERSION,          'refinery/seeder/version'

    class << self
      def templates_root
        @@templates_root
      end

      def templates_root=(root)
        @@templates_root = root
      end

      @@templates_root = File.expand_path(
        File.join('lib', 'seeds'),
        defined?(Rails) ? Rails.root : '.'
      )
    end
  end
end
