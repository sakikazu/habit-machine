require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe HabitsController do

  # This should return the minimal set of attributes required to create a valid
  # Habit. As you add validations to Habit, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "title" => "MyString" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # HabitsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all habits as @habits" do
      habit = Habit.create! valid_attributes
      get :index, {}, valid_session
      assigns(:habits).should eq([habit])
    end
  end

  describe "GET show" do
    it "assigns the requested habit as @habit" do
      habit = Habit.create! valid_attributes
      get :show, {:id => habit.to_param}, valid_session
      assigns(:habit).should eq(habit)
    end
  end

  describe "GET new" do
    it "assigns a new habit as @habit" do
      get :new, {}, valid_session
      assigns(:habit).should be_a_new(Habit)
    end
  end

  describe "GET edit" do
    it "assigns the requested habit as @habit" do
      habit = Habit.create! valid_attributes
      get :edit, {:id => habit.to_param}, valid_session
      assigns(:habit).should eq(habit)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Habit" do
        expect {
          post :create, {:habit => valid_attributes}, valid_session
        }.to change(Habit, :count).by(1)
      end

      it "assigns a newly created habit as @habit" do
        post :create, {:habit => valid_attributes}, valid_session
        assigns(:habit).should be_a(Habit)
        assigns(:habit).should be_persisted
      end

      it "redirects to the created habit" do
        post :create, {:habit => valid_attributes}, valid_session
        response.should redirect_to(Habit.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved habit as @habit" do
        # Trigger the behavior that occurs when invalid params are submitted
        Habit.any_instance.stub(:save).and_return(false)
        post :create, {:habit => { "title" => "invalid value" }}, valid_session
        assigns(:habit).should be_a_new(Habit)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Habit.any_instance.stub(:save).and_return(false)
        post :create, {:habit => { "title" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested habit" do
        habit = Habit.create! valid_attributes
        # Assuming there are no other habits in the database, this
        # specifies that the Habit created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Habit.any_instance.should_receive(:update_attributes).with({ "title" => "MyString" })
        put :update, {:id => habit.to_param, :habit => { "title" => "MyString" }}, valid_session
      end

      it "assigns the requested habit as @habit" do
        habit = Habit.create! valid_attributes
        put :update, {:id => habit.to_param, :habit => valid_attributes}, valid_session
        assigns(:habit).should eq(habit)
      end

      it "redirects to the habit" do
        habit = Habit.create! valid_attributes
        put :update, {:id => habit.to_param, :habit => valid_attributes}, valid_session
        response.should redirect_to(habit)
      end
    end

    describe "with invalid params" do
      it "assigns the habit as @habit" do
        habit = Habit.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Habit.any_instance.stub(:save).and_return(false)
        put :update, {:id => habit.to_param, :habit => { "title" => "invalid value" }}, valid_session
        assigns(:habit).should eq(habit)
      end

      it "re-renders the 'edit' template" do
        habit = Habit.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Habit.any_instance.stub(:save).and_return(false)
        put :update, {:id => habit.to_param, :habit => { "title" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested habit" do
      habit = Habit.create! valid_attributes
      expect {
        delete :destroy, {:id => habit.to_param}, valid_session
      }.to change(Habit, :count).by(-1)
    end

    it "redirects to the habits list" do
      habit = Habit.create! valid_attributes
      delete :destroy, {:id => habit.to_param}, valid_session
      response.should redirect_to(habits_url)
    end
  end

end
