require 'spec_helper'

describe "records/edit" do
  before(:each) do
    @record = assign(:record, stub_model(Record,
      :habit_id => 1,
      :recorddata_id => 1,
      :value => 1
    ))
  end

  it "renders the edit record form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => records_path(@record), :method => "post" do
      assert_select "input#record_habit_id", :name => "record[habit_id]"
      assert_select "input#record_recorddata_id", :name => "record[recorddata_id]"
      assert_select "input#record_value", :name => "record[value]"
    end
  end
end
