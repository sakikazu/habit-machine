require 'spec_helper'

describe "senses/index" do
  before(:each) do
    assign(:senses, [
      stub_model(Sense,
        :user_id => 1,
        :title => "Title",
        :description => "MyText",
        :content => "MyText",
        :is_active => false,
        :sort_order => 2
      ),
      stub_model(Sense,
        :user_id => 1,
        :title => "Title",
        :description => "MyText",
        :content => "MyText",
        :is_active => false,
        :sort_order => 2
      )
    ])
  end

  it "renders a list of senses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
