require 'spec_helper'
require 'refinery/seeder'


describe Refinery::Seeder do
  it "returns a default template search path" do
    subject.resources_root.should end_with('app/seeds')
  end

  it "allows setting the template search path" do
    old_root = subject.resources_root
    subject.resources_root = '.'
    subject.resources_root.should == '.'
    subject.resources_root = old_root
  end
end
