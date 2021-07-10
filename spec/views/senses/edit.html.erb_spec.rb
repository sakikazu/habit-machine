require 'spec_helper'

describe "senses/edit" do
  before(:each) do
    @sense = assign(:sense, stub_model(Sense,
      :user_id => 1,
      :title => "MyString",
      :description => "MyText",
      :content => "MyText",
      :is_active => false,
      :sort_order => 1
    ))
  end

  it "renders the edit sense form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", sense_path(@sense), "post" do
      assert_select "input#sense_user_id[name=?]", "sense[user_id]"
      assert_select "input#sense_title[name=?]", "sense[title]"
      assert_select "textarea#sense_description[name=?]", "sense[description]"
      assert_select "textarea#sense_content[name=?]", "sense[content]"
      assert_select "input#sense_is_active[name=?]", "sense[is_active]"
      assert_select "input#sense_sort_order[name=?]", "sense[sort_order]"
    end
  end
end
