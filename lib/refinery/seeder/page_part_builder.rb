require 'erb'
require 'refinery/seeder/ext'
require 'refinery/seeder/images/image_helper'


module Refinery::Seeder
  class PagePartBuilder

    attr_accessor :attributes, :page_builder, :part, :title

    def initialize(page_builder, title, attributes = {})
      @page_builder = page_builder
      @title = title
      @attributes = attributes.merge(title: title)
    end

    def templates_root
      File.join(Refinery::Seeder.resources_root, 'pages')
    end

    def template_search_path
      File.join(
        templates_root,
        @page_builder.title.underscored_word,
        "#{@title.underscored_word}.*"
      )
    end

    def template_path
      Dir[template_search_path].first
    end

    def render_body
      return nil if template_path.nil?
      ERB.new(File.read(template_path)).result(proc do
        extend Refinery::Seeder::Images::ImageHelper
        binding
      end.call)
    end

    def build(page)
      @attributes.merge! body: render_body
      part = page.part_with_title(title)

      if part.nil?
        part = page.parts.create!(@attributes)
      else
        part.update_attributes!(@attributes)
      end

      @part = part
    end
  end
end
