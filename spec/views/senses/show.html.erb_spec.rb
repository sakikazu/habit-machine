require 'spec_helper'

describe "senses/show" do
  before(:each) do
    @sense = assign(:sense, stub_model(Sense,
      :user_id => 1,
      :title => "Title",
      :description => "MyText",
      :content => "MyText",
      :is_active => false,
      :sort_order => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/false/)
    rendered.should match(/2/)
  end
end
