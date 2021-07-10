require 'spec_helper'

describe "diaries/edit" do
  before(:each) do
    @diary = assign(:diary, stub_model(Diary,
      :title => "MyString",
      :content => "MyText",
      :user_id => 1,
      :recorddate_id => 1
    ))
  end

  it "renders the edit diary form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => diaries_path(@diary), :method => "post" do
      assert_select "input#diary_title", :name => "diary[title]"
      assert_select "textarea#diary_content", :name => "diary[content]"
      assert_select "input#diary_user_id", :name => "diary[user_id]"
      assert_select "input#diary_recorddate_id", :name => "diary[recorddate_id]"
    end
  end
end
