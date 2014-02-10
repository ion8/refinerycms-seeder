require 'spec_helper'
require 'refinery/seeder/page_builder'


describe Refinery::Seeder::PageBuilder do
  let(:title) { "Home Page" }
  let(:attributes) { { slug: 'home' } }

  subject do
    Refinery::Seeder::PageBuilder.new(title, attributes)
  end

  it "should store its attributes" do
    subject.attributes.should == { title: "Home Page", slug: 'home' }
  end

  context "it builds a page object" do
    let(:page) { subject.build }
    it "assigns the stored attributes to the page object" do
      page.title.should == "Home Page"
      page.slug.should == 'home'
    end

    it "builds page objects that have an id" do
      page.id.should_not be_empty
    end
  end

end
