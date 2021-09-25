require 'spec_helper'

describe "habits/show" do
  before(:each) do
    @habit = assign(:habit, stub_model(Habit,
      :title => "Title",
      :graph_type => 1,
      :data_type => 2,
      :data_unit => "Data Unit",
      :reminder => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Data Unit/)
    rendered.should match(/false/)
  end
end
