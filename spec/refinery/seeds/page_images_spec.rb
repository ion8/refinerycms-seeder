require 'spec_helper'
require 'refinery/seeds/page_images_builder'


describe Refinery::Seeds::PageImagesBuilder do
  let(:page_builder) { double("Page", title: 'About Us', id: :the_page_id) }

  subject do
    Refinery::Seeds::PageImagesBuilder.new(page_builder)
  end

  it "does anything" do
    subject
  end

end
