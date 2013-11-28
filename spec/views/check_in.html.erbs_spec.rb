require 'spec_helper'

describe "CheckIn.html.erbs" do
  describe "GET /check_in.html.erbs" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get check_in.html.erbs_path
      response.status.should be(200)
    end
  end
end
