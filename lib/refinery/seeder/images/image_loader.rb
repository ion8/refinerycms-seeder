module Refinery::Seeder
  module Images
    class ImageLoadError < IOError; end

    class ImageLoader
      IMAGE_FILE_RE = Regexp.compile(/\.(png|jpe?g|gif)$/i)

      def images_root
        File.join(Refinery::Seeder.resources_root, 'images')
      end

      def collect_image_paths
        unless File.directory?(images_root)
          raise ImageLoadError.new(
            "images root #{images_root} is not a directory")
        end

        Dir[File.join(images_root, '**/*')].select do |file|
          File.file?(file) && File.readable?(file) && file =~ IMAGE_FILE_RE
        end
      end

      def load_image_files
        Hash[
          collect_image_paths.map do |path|
            [path.gsub(/^#{images_root}#{File::SEPARATOR}+/, ''), File.new(path)]
          end
        ]
      end
    end
  end
end
