require "spec_helper"

describe SensesController do
  describe "routing" do

    it "routes to #index" do
      get("/senses").should route_to("senses#index")
    end

    it "routes to #new" do
      get("/senses/new").should route_to("senses#new")
    end

    it "routes to #show" do
      get("/senses/1").should route_to("senses#show", :id => "1")
    end

    it "routes to #edit" do
      get("/senses/1/edit").should route_to("senses#edit", :id => "1")
    end

    it "routes to #create" do
      post("/senses").should route_to("senses#create")
    end

    it "routes to #update" do
      put("/senses/1").should route_to("senses#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/senses/1").should route_to("senses#destroy", :id => "1")
    end

  end
end
