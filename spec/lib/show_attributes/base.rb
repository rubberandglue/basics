require 'spec_helper'

describe ShowAttributes::Base do
  let(:object) { stub(:banane) }

  context '#title' do
    it "displays localized class name" do
      object.class.should_receive(:human_attribute_name).with(:wohoo)
      sa = ShowAttributes::Base.new(object)
      sa.title(:wohoo)
    end
  end

  context "#value" do
    let(:column) { ShowAttributes::Column.new(object, :xyz) }

    it "displays association" do
      sa = ShowAttributes::Base.new(object)
      sa.stub(:column).and_return(column)
      column.should_receive(:value)
      sa.value(:affe)
    end
  end

  context '#dl'
  context '#li'
end