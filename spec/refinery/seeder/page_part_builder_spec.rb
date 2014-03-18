require 'spec_helper'
require 'refinery/seeder/page_part_builder'


describe Refinery::Seeder::PagePartBuilder do
  let(:title) { "Body" }
  let(:attributes) { { position: 1 } }
  let(:page) { double("Page", title: 'About Us', id: :the_page_id) }

  subject do
    Refinery::Seeder::PagePartBuilder.new(page, title, attributes)
  end

  it "stores its attributes" do
    subject.attributes.should == {
      title: title,
      position: attributes[:position]
    }
    subject.title.should == title
    subject.page.should == page
  end

  context "template search paths" do

    before :each do
      Refinery::Seeder.should respond_to :resources_root
      allow(Refinery::Seeder).to receive(:resources_root).and_return File.join(
        File.expand_path('../../..', __FILE__), # spec/
        'resources'
      )
    end

    let(:template_search_path) { subject.template_search_path }

    it "has a template root path" do
      subject.templates_root.should_not be_empty
      subject.templates_root.should start_with Refinery::Seeder.resources_root
      subject.templates_root.should end_with 'pages'
    end

    it "derives a search path to a template for its body" do
      template_search_path.should start_with Refinery::Seeder.resources_root
      template_search_path.should include title.underscored_word
      template_search_path.should include page.title.underscored_word
      template_search_path.should end_with '.*'
    end

    context "locates a template for the body" do
      it "locates an existing template" do
        subject.template_path.should == File.expand_path(
          File.join(*%w(spec resources pages about_us body.html.erb))
        )
      end

      it "returns nil when no template is found" do
        subject.title = "does not exist"
        subject.template_path.should be_nil
      end
    end

    context "it gets the body from a template" do
      it "renders the body from the template" do
        subject.render_body.should include 'This is the body'
      end

      it "returns nil when no template is found" do
        subject.title = "does not exist"
        subject.render_body.should be_nil
      end
    end

    context "builds page parts" do
      let(:merged_attributes) do
        attributes.merge(title: title, body: subject.render_body)
      end

      it "builds a new PagePart if it doesn't exist" do
        expect(page).to receive(:part_with_title).with(title).and_return nil
        parts_relation = double("parts relation")
        expect(page).to receive(:parts).and_return parts_relation
        expect(parts_relation).to receive(:create!).with(merged_attributes).
          and_return :a_new_page
        subject.build.should be :a_new_page
      end

      it "sets attributes on an existing PagePart" do
        page_part = double("existing page part")
        expect(page).to receive(:part_with_title).with(title).and_return page_part
        expect(page_part).to receive(:update!).with(merged_attributes)
        subject.build.should be page_part
      end
    end

  end
end

