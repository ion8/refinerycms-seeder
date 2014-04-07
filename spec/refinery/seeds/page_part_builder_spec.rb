require 'spec_helper'
require 'refinery/seeds/page_part_builder'


describe Refinery::Seeds::PagePartBuilder do
  let(:title) { "Body" }
  let(:attributes) { { position: 1 } }
  let(:page_builder) { double("Page", title: 'About Us', id: :the_page_id) }

  subject do
    Refinery::Seeds::PagePartBuilder.new(page_builder, title, attributes)
  end

  it "stores its attributes" do
    subject.attributes.should == {
      title: title,
      position: attributes[:position]
    }
    subject.title.should == title
    subject.page_builder.should == page_builder
  end

  context "template search paths" do

    before :each do
      Refinery::Seeds.should respond_to :resources_root
      allow(Refinery::Seeds).to receive(:resources_root).and_return File.join(
        File.expand_path('../../..', __FILE__), # spec/
        'resources'
      )
    end

    let(:template_search_path) { subject.template_search_path }

    it "has a template root path" do
      subject.templates_root.should_not be_empty
      subject.templates_root.should start_with Refinery::Seeds.resources_root
      subject.templates_root.should end_with 'pages'
    end

    it "derives a search path to a template for its body" do
      template_search_path.should start_with Refinery::Seeds.resources_root
      template_search_path.should include title.underscored_word
      template_search_path.should include page_builder.title.underscored_word
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

      context "when part doesn't exist" do
        let(:parts) { double("parts", create!: :a_new_part) }
        let(:page) { double("page", part_with_title: nil, parts: parts) }

        it "creates a new PagePart" do
          subject.part.should be_nil
          subject.build(page).should be :a_new_part
          subject.part.should be :a_new_part
        end

        it "renders the body and stores it in @attributes" do
          subject.build(page)
          subject.attributes.should include :body
        end
      end

      context "when part already exists" do
        let(:part) { double("part", update_attributes!: :pretended_to) }
        let(:page) { double("page", part_with_title: part) }

        it "sets attributes on an existing PagePart" do
          subject.part.should be_nil
          expect(part).to receive(:update_attributes!)
          subject.build(page).should be part
          subject.part.should be part
        end
      end
    end

  end
end

