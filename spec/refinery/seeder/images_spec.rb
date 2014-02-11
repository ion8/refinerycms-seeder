require 'spec_helper'
require 'refinery/seeder/images'


describe Refinery::Seeder::Images::ImageLoader do
  subject { Refinery::Seeder::Images::ImageLoader.new }

  it "has an image root path" do
    subject.images_root.should_not be_empty
    subject.images_root.should start_with Refinery::Seeder.resources_root
    subject.images_root.should end_with 'images'
  end
end
