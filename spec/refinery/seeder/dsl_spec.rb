require 'spec_helper'
require 'refinery/seeder/dsl'
require 'refinery/seeder/page_builder'


describe Refinery::Seeder::DSL do

  let(:dsl) { Refinery::Seeder::DSL }

  it "executes a block in the context of itself" do
    expect(dsl).to receive(:new).once.and_call_original

    dsl.evaluate do
      # this also tests that methods in the outer context
      # are also available in the block (due to let(:dsl))
      self.class.should == dsl
      :evaluated
    end.should be :evaluated
  end

  context "page syntax" do

    let(:page_builder_class) { double('PageBuilder') }
    let(:page_builder) { double("page_builder") }
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

    context "page with no parts" do

      before :each do
        expect(dsl).to receive(:new).twice.and_call_original
      end

      it "creates a PageBuilder instance and exposes it through #page" do
        # Gotta work around rspec's magic here
        # not testing the dynamic writers to act like you have
        # no writable attributes
        allow(page_builder).to receive(:writable?).and_return false

        dsl.evaluate do
          page(*page_args) do
            page.should be page_builder
          end
        end
      end

      it "allows setting page attributes in the block with #set" do
        expect(page_builder).to receive(:set).with(:slug, 'some-slug')

        dsl.evaluate do
          page(*page_args) do
            set :slug, 'some-slug'
          end
        end
      end

      it "allows setting page attributes in the block with dynamic writers" do
        expect(page_builder).to receive(:set).with(:slug, 'another-slug')
        allow(page_builder).to receive(:writable?).
          with(:slug).and_return true

        dsl.evaluate do
          page(*page_args) do
            slug 'another-slug'
          end
        end
      end

    end

    context "defining a part within a page block" do

      before :each do
        expect(dsl).to receive(:new).twice.and_call_original
        page_part_builder = double("page_part_builder")
        stub_const 'Refinery::Seeder::PagePartBuilder',
          double('PagePartBuilder', new: page_part_builder)
      end

      it "defines a part to build with #part" do
        part_args = ['Body', {}]

        expect(page_builder).to receive(:add_part)

        dsl.evaluate do
          page(*page_args) do
            part(*part_args)
          end
        end
      end

      it "allows parts to be kept by title, without defining it" do
        expect(page_builder).to receive(:keep_part).with('Body')

        dsl.evaluate do
          page(*page_args) do
            keep_part 'Body'
          end
        end
      end

    end
  end
end
