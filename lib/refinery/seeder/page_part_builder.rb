require 'erb'


module Refinery::Seeder
  class PagePartBuilder
    attr_accessor :attributes, :page, :title

    def initialize(page, title, attributes = {})
      @page = page
      @title = title
      @attributes = attributes.merge(title: title, refinery_page_id: page.id)
    end

    def templates_root
      File.join(Refinery::Seeder.resources_root, 'pages')
    end

    def template_search_path
      File.join(
        templates_root,
        @page.title.underscored_word,
        "#{@title.underscored_word}.*"
      )
    end

    def template_path
      Dir[template_search_path].first
    end

    def render_body
      return nil if template_path.nil?
      ERB.new(File.read(template_path)).result
    end
  end
end
