module Refinery::Seeds
  module Images
    class ImageLoadError < IOError; end

    class ImageLoader
      attr_accessor :images

      IMAGE_FILE_RE = Regexp.compile(/\.(png|jpe?g|gif)$/i)

      def self.load_images
        @@loader = new
        @@loader.load_images
      end

      def self.loader
        @@loader
      end

      def self.images
        @@loader.images
      end

      def initialize
        @images = {}
      end

      def images_root
        File.join(Refinery::Seeds.resources_root, 'images')
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

      ##
      # returns a hash mapping paths (relative to the images_root)
      # to File handles of the corresponding images.
      def collect_image_files
        Hash[
          collect_image_paths.map do |path|
            [path.gsub(/^#{images_root}#{File::SEPARATOR}+/, ''), File.new(path)]
          end
        ]
      end

      ##
      # Loads a hash mapping paths (relative to the images_root)
      # to persisted Refinery::Image references into the +images+
      # instance attribute, and returns it.
      def load_images
        @images = Hash[
          collect_image_files.map do |path, file|
            uid = "seeds:#{path}"
            image = (
              Refinery::Image.find_by_image_uid(uid) ||
              Refinery::Image.create!(image: file) { |i| i.image_uid = uid }
            )

            [path, image]
          end
        ]
        @images
      end
    end
  end
end
