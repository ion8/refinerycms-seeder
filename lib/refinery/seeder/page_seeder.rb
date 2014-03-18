require 'refinery/pages'
require 'refinery/images'

module Refinery
  autoload :Page, 'refinery/pages'
  autoload :Image, 'refinery/images'
end

=begin
module Refinery
  module Seeder
    class PageSeeder

      class << self
        def create_page(slug, options = {}, &block)
          p = Refinery::Page.where(slug: slug).first

          if p.nil?
            options[:title] ||= slug.titlecase
            options[:custom_slug] = slug
            p = Refinery::Page.create(options)
          else
            p.update_attributes(options)
          end

          page_seeder = new(p)
          page_seeder.load_images
          page_seeder.evaluate(&block)
        end
      end

      def initialize(slug, options = {}, &block)
        page = ::Refinery::Page.where(slug: slug).first

        @page = page
      end

      def load_images
        @images = {}
        dir = File.join(Rails.root, 'lib', 'seeds', 'pages', @page.slug, 'images')
        return unless File.directory?(dir)

        Dir[File.join(dir, '*')].each do |file|
          next unless File.file?(file) && File.readable?(file)

          base = File.basename(file)
          # uid = "#{@page.slug}_#{base}"
          #
          image = Refinery::Image.create!(image: File.new(file))

          @images[base] = image
        end
      end

      def image(name)
        @images.fetch(name)
      end

      def insert_image(name, geometry = nil, options = {})
        img = @images.fetch(name)

        title = img.title

        img = img.thumbnail(geometry: geometry) unless geometry.nil?

        options = {
          title: title,
          alt: title,
          width: img.width,
          height: img.height,
        }.merge(options)

        options[:src] = img.url

        %{
          <img
          src="#{options[:src]}"
          title="#{options[:title]}"
          alt="#{options[:alt]}"
          width="#{options[:width]}"
          height="#{options[:height]}"
          >
        }
      end

      def part(title, body = nil)
        body = load_template(@page.slug, title) if body.nil?
        part = @page.part_with_title(title)
        if part.nil?
          @page.parts.create(title: title, body: body)
        else
          part.body = body
          part.save
        end
      end

      def method_missing(method, *args, &block)
        @self_before_instance_eval.send(method, *args, &block)
      end

      def evaluate(&block)
        @self_before_instance_eval = eval("self", block.binding)
        instance_eval(&block)
      end

      protected

      def load_template(page_slug, part_title)
        part_underscored = part_title.titlecase.gsub(/\s+/, '').underscore
        filename = File.join(Rails.root, 'lib', 'seeds', 'pages', page_slug, "#{part_underscored}.html")

        return nil unless File.readable?(filename)

        ERB.new(File.read(filename)).result(binding)
      end

    end

  end
end
=end
