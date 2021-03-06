require 'spec_helper'
require 'refinery/pages'
require 'refinery/seeds/page_builder'


describe Refinery::Seeds::PageBuilder do
  let(:title) { "Home Page" }
  let(:slug) { 'home' }
  let(:attributes) { { title: title, slug: slug } }

  subject do
    Refinery::Seeds::PageBuilder.new(title, { slug: slug })
  end

  before :each do
    stub_const 'Refinery::Page', double('Refinery::Page')
  end

  context "attributes specification" do
    before :each do
      # the accessible attributes array has indifferent access
      # but it's not worth testing, so this is all dealing with Strings.
      accessible_attributes = %w(title foo bar)
      allow(Refinery::Page).to receive(:accessible_attributes).
        and_return accessible_attributes
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

  context "template search paths" do
    before :each do
      Refinery::Seeds.should respond_to :resources_root
      allow(Refinery::Seeds).to receive(:resources_root).and_return File.join(
        File.expand_path('../../..', __FILE__), # spec/
        'resources'
      )
    end

    it "has a template root path" do
      subject.templates_root.should_not be_empty
      subject.templates_root.should start_with Refinery::Seeds.resources_root
      subject.templates_root.should end_with 'pages'
    end

  end

  context "builds pages" do
    before do
      # TODO: test when force is not true
      ENV['FORCE'] = 'true'
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

    it "builds parts and designates them to be kept after clean_parts!" do
      subject.add_part(
        double("body part builder",
               build: double("body part", title: "Body")))
      subject.add_part(
        double("side part builder",
               build: double("side part", title: "Side Body")))

      expect(subject).to receive(:keep_part).with("Body")
      expect(subject).to receive(:keep_part).with("Side Body")
      subject.build_parts
    end
  end

  context "only keeps parts that are defined or kept explicitly" do
    let(:page) do
      double("page", parts: [
        double("one part", title: "one part"),
        double("another part", title: "another part")
      ])
    end

    it "clean_parts! when page isn't set yet is a no-op" do
      subject.page.should be_nil
      subject.clean_parts!.should be_false
    end

    it "clean_parts! destroys unkept parts" do
      subject.page = page
      page.parts.each do |p|
        expect(p).to receive(:destroy)
      end
      subject.clean_parts!.should == 2
    end

    it "#keep_part adds to a list of parts that should be kept" do
      subject.page = page
      subject.keep_part page.parts[0].title
      expect(page.parts[1]).to receive(:destroy)
      subject.clean_parts!.should == 1
    end

    it "kept part title names are case insensitive" do
      subject.page = page
      subject.keep_part page.parts[0].title.upcase
      expect(page.parts[1]).to receive(:destroy)
      subject.clean_parts!.should == 1
    end

    context "it cleans parts after build" do

      before :each do
        allow(Refinery::Page).to receive(:by_title).and_return [nil]
        allow(Refinery::Page).to receive(:create!)
      end

      it "does not call clean_parts! by default" do
        subject.will_clean_parts.should be_false
        expect(subject).to receive(:will_clean_parts?).and_call_original
        expect(subject).to_not receive(:clean_parts!)
        subject.build
      end

      it "will call clean_parts! if will_clean_parts is set to true" do
        subject.will_clean_parts = true
        expect(subject).to receive(:will_clean_parts?).and_call_original
        expect(subject).to receive(:clean_parts!)
        subject.build
      end

    end
  end

end
