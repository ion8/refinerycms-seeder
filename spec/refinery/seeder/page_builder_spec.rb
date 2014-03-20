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

  context "attributes specification" do
    it "should store its attributes from initialization" do
      subject.attributes.should == attributes
    end

    it "exposes which attributes are writable" do
      accessible_attributes = %w(title foo bar)
      refinery_page = double("Refinery::Page",
                             accessible_attributes: accessible_attributes)
      stub_const('Refinery::Page', refinery_page)

      # can't overwrite title
      subject.writable?('title').should be_false

      subject.writable?('foo').should be_true
      subject.writable?('bar').should be_true
      subject.writable?('baz').should be_false
    end
  end

  context "builds pages" do
    before :each do
      stub_const 'Refinery::Page', double('Refinery::Page')
    end

    it "builds a new Page if it does not exist" do
      expect(Refinery::Page).to receive(:by_title).and_return nil
      expect(Refinery::Page).to receive(:create!).with(attributes).
        and_return :a_new_page
      subject.build.should be :a_new_page
    end

    it "sets attributes on an existing page" do
      some_page = double("page")
      expect(Refinery::Page).to receive(:by_title).and_return some_page
      expect(some_page).to receive(:update!).with(attributes)
      subject.build.should be some_page
    end
  end

end
