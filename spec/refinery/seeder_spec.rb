require 'spec_helper'
require 'refinery/seeder'


describe Refinery::Seeder do
  it "returns a default template search path" do
    subject.templates_root.should end_with('lib/seeds')
  end

  it "allows setting the template search path" do
    old_root = subject.templates_root
    subject.templates_root = '.'
    subject.templates_root.should == '.'
    subject.templates_root = old_root
  end
end
