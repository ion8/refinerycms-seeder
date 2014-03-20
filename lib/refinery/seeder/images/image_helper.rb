require 'refinery/seeder/images/image_loader'


module Refinery::Seeder::Images
  module ImageHelper
    def images
      Refinery::Seeder::Images::ImageLoader.images
    end

    def insert_image(name, geometry = nil, options = {})
      img = images.fetch(name)
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
  end
end
