require 'spec_helper'

describe "records/new" do
  before(:each) do
    assign(:record, stub_model(Record,
      :habit_id => 1,
      :recorddata_id => 1,
      :value => 1
    ).as_new_record)
  end

  it "renders new record form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => records_path, :method => "post" do
      assert_select "input#record_habit_id", :name => "record[habit_id]"
      assert_select "input#record_recorddata_id", :name => "record[recorddata_id]"
      assert_select "input#record_value", :name => "record[value]"
    end
  end
end
