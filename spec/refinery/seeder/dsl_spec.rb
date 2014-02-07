require 'spec_helper'
require 'refinery/seeder/dsl'
require 'refinery/seeder/page_builder'


describe Refinery::Seeder::DSL do

  let(:dsl) { Refinery::Seeder::DSL }

  it "executes a block in the context of itself" do
    dsl.evaluate do
      # this also tests that methods in the outer context
      # are also available in the block (due to let(:dsl))
      self.class.should == dsl
      :evaluated
    end.should be :evaluated
  end

  context "page syntax" do

    let(:page_builder_class) { double('PageBuilder') }
    let(:page_builder) { Struct.new(:title, :slug).new }
    let(:page_args) { ['Home Page', { slug: 'home' }] }

    before :each do
      expect(page_builder_class).to(
        receive(:new).once
        .with(*page_args)
        .and_return(page_builder)
      )
      expect(page_builder).to receive(:build).once
      stub_const('Refinery::Seeder::PageBuilder', page_builder_class)
    end

    it "creates a PageBuilder instance and exposes it through #page" do
      dsl.evaluate do
        page(*page_args) do
          page.should be page_builder
        end
      end
    end

    it "allows setting page attributes in the block" do
      expect(page_builder).to receive(:slug=).and_call_original.twice

      dsl.evaluate do
        page(*page_args) do
          slug 'custom-slug'
          (page_builder.slug.should == 'custom-slug')

          set :slug, 'another-slug'
          (page_builder.slug.should == 'another-slug')
        end
      end
    end

    context "page part syntax" do
      it "creates a PagePartBuilder instance and exposes it through #part" do
        part_args = ['Body', {}]
        page_part_builder_class = double("PagePartBuilder")
        page_part_builder = double("PagePartBuilder")

        expect(page_part_builder_class).to(
          receive(:new).once
          .with(*part_args)
          .and_return(page_part_builder)
        )

        expect(page_part_builder).to receive(:build).once

        stub_const(
          'Refinery::Seeder::PagePartBuilder',
          page_part_builder_class
        )

        dsl.evaluate do
          page(*page_args) do
            part(*part_args)
          end
        end
      end
    end

  end

end
