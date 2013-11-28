require 'spec_helper'

describe "CheckOut.html.erbs" do
  describe "GET /check_out.html.erbs" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get check_out.html.erbs_path
      response.status.should be(200)
    end
  end
end
