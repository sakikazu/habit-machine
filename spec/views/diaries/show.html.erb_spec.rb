require 'spec_helper'

describe "diaries/show" do
  before(:each) do
    @diary = assign(:diary, stub_model(Diary,
      :title => "Title",
      :content => "MyText",
      :user_id => 1,
      :recorddate_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
