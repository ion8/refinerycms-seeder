require 'spec_helper'
require 'refinery/pages'
require 'refinery/seeder/page_builder'


describe Refinery::Seeder::PageBuilder do
  let(:title) { "Home Page" }
  let(:slug) { 'home' }
  let(:attributes) { { title: title, slug: slug } }

  subject do
    Refinery::Seeder::PageBuilder.new(title, { slug: slug })
  end

  it "should store its attributes" do
    subject.attributes.should == attributes
  end

  context "builds pages" do
    before :each do
      stub_const 'Refinery::Page', double('Refinery::Page')
    end

    it "builds a new Page if it does not exist" do
      expect(Refinery::Page).to receive(:by_title).and_return nil
      expect(Refinery::Page).to receive(:create!).with(attributes)
      subject.build
    end

    it "sets attributes on an existing page"
  end

end
