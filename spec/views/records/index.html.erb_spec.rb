require 'spec_helper'

describe "records/index" do
  before(:each) do
    assign(:records, [
      stub_model(Record,
        :habit_id => 1,
        :recorddata_id => 2,
        :value => 3
      ),
      stub_model(Record,
        :habit_id => 1,
        :recorddata_id => 2,
        :value => 3
      )
    ])
  end

  it "renders a list of records" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
