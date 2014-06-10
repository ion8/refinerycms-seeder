require 'refinery/seeds/images/image_loader'


module Refinery::Seeds
  class PageImagesBuilder

    attr_accessor :page_builder

    def initialize(page_builder)
      @page_builder = page_builder
    end

    def images_root
      File.join(
        @page_builder.template_search_path,
        'images'
      )
    end

    def image_search_path
      File.join(
        images_root,
        '*.{jpg,JPG,jpeg,JPEG,gif,GIF,png,PNG}'
      )
    end

    def image_paths
      if File.directory?(images_root)
        Dir[image_search_path].select do |path|
          File.file?(path) && File.readable?(path)
        end
      else
        []
      end
    end

    def caption_template_for_image(image_path)
      path = Dir[image_path.sub(/(.*)\..+$/, '\1.html.erb')].first
      path if File.file?(path) && File.readable?(path)
    end

    def render_caption(template_path)
      return nil if template_path.nil?
      ERB.new(File.read(template_path)).result
    end

    def build(page)
      begin
        require 'refinery/page_images'
      rescue LoadError
        $stderr.puts "Trying to load page-images but can't load refinery/page_images"
        return
      end

      image_paths.each do |image_path|
        image = Refinery::Image.create!(image: File.new(image_path))

        template = caption_template_for_image(image_path)
        caption = render_caption(template) unless template.nil?

        image_page = page.image_pages.find_by_image_id(image.id)
        if image_page.nil?
          image_page = page.image_pages.create!(image_id: image.id) do |pi|
            pi.caption = caption
          end
        elsif ENV['FORCE']
          image_page.caption = caption
          image_page.save
        end
      end
    end
  end
end
