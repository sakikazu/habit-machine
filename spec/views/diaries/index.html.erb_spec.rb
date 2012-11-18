require 'spec_helper'

describe "diaries/index" do
  before(:each) do
    assign(:diaries, [
      stub_model(Diary,
        :title => "Title",
        :content => "MyText",
        :user_id => 1,
        :recorddate_id => 2
      ),
      stub_model(Diary,
        :title => "Title",
        :content => "MyText",
        :user_id => 1,
        :recorddate_id => 2
      )
    ])
  end

  it "renders a list of diaries" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
