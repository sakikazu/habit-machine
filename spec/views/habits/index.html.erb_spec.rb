require 'spec_helper'

describe "habits/index" do
  before(:each) do
    assign(:habits, [
      stub_model(Habit,
        :title => "Title",
        :graph_type => 1,
        :data_type => 2,
        :data_unit => "Data Unit",
        :reminder => false
      ),
      stub_model(Habit,
        :title => "Title",
        :graph_type => 1,
        :data_type => 2,
        :data_unit => "Data Unit",
        :reminder => false
      )
    ])
  end

  it "renders a list of habits" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Data Unit".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
