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
    before :each do
      # the accessible attributes array has indifferent access
      # but it's not worth testing, so this is all dealing with Strings.
      accessible_attributes = %w(title foo bar)
      refinery_page = double("Refinery::Page",
                             accessible_attributes: accessible_attributes)
      stub_const('Refinery::Page', refinery_page)
    end

    it "should store its attributes from initialization" do
      subject.attributes.should == attributes
    end

    it "exposes which attributes are writable" do

      # can't overwrite title
      subject.writable?('title').should be_false

      subject.writable?('foo').should be_true
      subject.writable?('bar').should be_true
      subject.writable?('baz').should be_false
    end

    it "doesn't allow title to be overwritten" do
      expect { subject.set 'title', 'new title' }.to raise_error(ArgumentError)
    end

    it "doesn't allow non-accessible attributes to be overwritten" do
      expect { subject.set 'baz', 123 }.to raise_error(ArgumentError)
    end

    it "allows attributes to be set" do
      subject.attributes['foo'].should be_nil
      subject.set 'foo', 123
      subject.attributes['foo'].should == 123
    end
  end

  context "builds pages" do
    before :each do
      stub_const 'Refinery::Page', double('Refinery::Page')
    end

    it "manages a list of contained parts to build" do
      page_part_builder = double("page_part_builder")
      subject.add_part(page_part_builder)
      subject.part_builders.should include page_part_builder
    end

    it "builds a new Page if it does not exist" do
      expect(Refinery::Page).to receive(:by_title).and_return [nil]
      expect(Refinery::Page).to receive(:create!).with(attributes).
        and_return :a_new_page
      expect(subject).to receive(:build_parts)
      subject.build.should be :a_new_page
      subject.page.should be :a_new_page
    end

    it "sets attributes on an existing page" do
      some_page = double("page")
      expect(Refinery::Page).to receive(:by_title).and_return [some_page]
      expect(some_page).to receive(:update_attributes!).with(attributes)
      expect(subject).to receive(:build_parts)
      subject.build.should be some_page
      subject.page.should be some_page
    end
  end

end
