module Refinery::Seeder
  module Images
    class ImageLoader
      def images_root
        File.join(Refinery::Seeder.resources_root, 'images')
      end
    end
  end
end
