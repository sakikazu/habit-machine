require 'spec_helper'

describe "habits/edit" do
  before(:each) do
    @habit = assign(:habit, stub_model(Habit,
      :title => "MyString",
      :graph_type => 1,
      :data_type => 1,
      :data_unit => "MyString",
      :reminder => false
    ))
  end

  it "renders the edit habit form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => habits_path(@habit), :method => "post" do
      assert_select "input#habit_title", :name => "habit[title]"
      assert_select "input#habit_graph_type", :name => "habit[graph_type]"
      assert_select "input#habit_data_type", :name => "habit[data_type]"
      assert_select "input#habit_data_unit", :name => "habit[data_unit]"
      assert_select "input#habit_reminder", :name => "habit[reminder]"
    end
  end
end
