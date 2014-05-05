require 'spec_helper'
require 'refinery/seeds/images'


describe Refinery::Seeds::Images::ImageLoader do
  subject { Refinery::Seeds::Images::ImageLoader.new }

  it "has an image root path" do
    subject.images_root.should_not be_empty
    subject.images_root.should start_with Refinery::Seeds.resources_root
    subject.images_root.should end_with 'images'
  end

  context "insert_image helper for use in templates" do
    let(:image) do
      double("Refinery::Image",
             title: 'Name',
             width: 80,
             height: 40,
             url: 'http://example.com/name.jpg')
    end

    let(:helpers) do
      Object.new.extend(Refinery::Seeds::Images::ImageHelper)
    end

    before :each do
      allow(image).to receive(:thumbnail).and_return image
      img = image
      helpers.send(:define_singleton_method, :images) {{ 'name.jpg' => img }}
    end

    it "basic invocation" do
      img_tag = helpers.insert_image('name.jpg')

      img_tag.should include "src=\"#{image.url}\""
      img_tag.should include 'title="Name"'
    end

    it "invocation with geometry" do
      expect(image).to receive(:thumbnail).with(geometry: :small).
        and_return image
      helpers.insert_image('name.jpg', :small)
    end

    it "invocation with options" do
      img_tag = helpers.insert_image('name.jpg', nil, { alt: 'some alt text' })
      img_tag.should include 'alt="some alt text"'
    end
  end

  context "loads images" do
    before :each do
      allow(Refinery::Seeds).to receive(:resources_root).and_return File.join(
        File.expand_path('../../..', __FILE__), # spec/
        'resources'
      )
    end

    let(:paths) { ["blue.PNG", "green.png", File.join("subdir", "red.png")] }
    let(:long_paths) { paths.map { |p| File.join(subject.images_root, p) } }
    let(:files) { long_paths.map { |p| File.new(p) } }

    it "collects paths to images" do
      paths = subject.collect_image_paths
      paths.length.should == 3
      paths.to_set.should == long_paths.to_set
    end

    it "collects file references to images" do
      expect(subject).to receive(:collect_image_paths).once.
        and_return long_paths
      file_map = subject.collect_image_files
      file_map.keys.to_set.should == paths.to_set
      file_map['green.png'].should be_a File
    end

    it "creates Refinery::Image records with the files" do
      allow(subject).to receive(:collect_image_files).
        and_return Hash[paths.zip files]

      stub_const('Refinery::Image', refinery_image = double('Refinery::Image'))

      files = subject.collect_image_files

      files.each do |path, file|
        expect(refinery_image).to receive(:find_by_image_uid).and_return nil
        expect(refinery_image).to receive(:create!).with(image: file)
      end

      images = subject.load_images
      images.should be subject.images
      images.length.should == paths.length
    end
  end
end
