module Refinery::Seeder
  module Images
    class ImageLoadError < IOError; end

    class ImageLoader
      def images_root
        File.join(Refinery::Seeder.resources_root, 'images')
      end

      def collect_image_paths
        unless File.directory?(images_root)
          raise ImageLoadError.new(
            "images root #{images_root} is not a directory")
        end

        Dir[File.join(images_root, '**/*')].select do |file|
          File.file?(file) && File.readable?(file) && (
            file =~ /\.(png|jpe?g|gif)$/i
          )
        end
      end
    end
  end
end
