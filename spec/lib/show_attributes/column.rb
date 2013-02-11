require 'spec_helper'

describe ShowAttributes::Column do
  let(:object) { stub(:banane) }
  let(:column) { ShowAttributes::Column.new(object, :wohoo) }
  subject { column }

  context '#title' do
    it "displays localized class name" do
      object.class.should_receive(:human_attribute_name).with(:wohoo)
      subject.title
    end
  end

  context '#raw_value' do
    it 'send column name to object' do
      object.should_receive(:wohoo)
      column.raw_value
    end
  end

  context "#value" do
    it "displays association" do
      column.stub(:association?).and_return(true)
      column.should_receive(:association_name).with(object, :wohoo)
      column.value
    end

    it "displays boolean" do
      column.stub(:association?).and_return(false)
      column.stub(:boolean?).and_return(true)
      column.stub(:raw_value)
      column.should_receive(:boolean_tag)
      column.value
    end

    it "display raw value as default" do
      column.stub(:association?).and_return(false)
      column.stub(:boolean?).and_return(false)
      column.should_receive(:raw_value)
      column.value
    end

    it "displays default symbol" do
      column.stub(:association?).and_return(false)
      column.stub(:boolean?).and_return(false)
      column.stub(:raw_value).and_return(nil)
      column.value.should == '-'
    end
  end
end