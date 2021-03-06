require 'refinery/pages'

require 'refinery/seeds/ext'


module Refinery::Seeds
  class PageBuilder
    attr_accessor :attributes, :title, :page, :part_builders,
                  :will_clean_parts

    alias_method :will_clean_parts?, :will_clean_parts

    def initialize(title, attributes = {})
      @title = title
      @attributes = attributes.merge(title: title)
      @part_builders = []
      @kept_part_titles = []
      @will_clean_parts = false
    end

    def writable?(attribute)
      return false if attribute.to_s == 'title'
      Refinery::Page.accessible_attributes.include? attribute
    end

    def set(attribute, value)
      if writable? attribute
        @attributes[attribute] = value
      else
        raise ArgumentError, "Can't write #{attribute} attribute"
      end
    end

    def templates_root
      File.join(Refinery::Seeds.resources_root, 'pages')
    end

    def template_search_path
      File.join(
        templates_root,
        title.underscored_word
      )
    end

    def add_part(part_builder)
      @part_builders << part_builder
    end

    def add_page_images(page_images_builder)
      @page_images_builder = page_images_builder
    end

    def build
      page = Refinery::Page.by_title(@title).first

      if page.nil?
        page = Refinery::Page.create!(@attributes)
      elsif ENV['FORCE'].present?
        page.update_attributes!(@attributes)
      end

      @page = page
      build_parts
      clean_parts! if will_clean_parts?

      build_page_images if @page_images_builder

      @page
    end

    def build_parts
      @part_builders.each do |part_builder|
        part = part_builder.build(@page)
        keep_part part.title
      end
    end

    def keep_part(part_title)
      @kept_part_titles << part_title
    end

    def clean_parts!
      if @page.nil?
        false
      else
        parts_to_destroy = @page.parts.reject do |part|
          @kept_part_titles.map(&:downcase).include?(part.title.downcase)
        end
        parts_to_destroy.each(&:destroy)
        parts_to_destroy.length
      end
    end

    def build_page_images
      @page_images_builder.build(@page)
    end
  end
end
