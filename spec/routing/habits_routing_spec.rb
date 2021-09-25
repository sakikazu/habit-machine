require "spec_helper"

describe HabitsController do
  describe "routing" do

    it "routes to #index" do
      get("/habits").should route_to("habits#index")
    end

    it "routes to #new" do
      get("/habits/new").should route_to("habits#new")
    end

    it "routes to #show" do
      get("/habits/1").should route_to("habits#show", :id => "1")
    end

    it "routes to #edit" do
      get("/habits/1/edit").should route_to("habits#edit", :id => "1")
    end

    it "routes to #create" do
      post("/habits").should route_to("habits#create")
    end

    it "routes to #update" do
      put("/habits/1").should route_to("habits#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/habits/1").should route_to("habits#destroy", :id => "1")
    end

  end
end
