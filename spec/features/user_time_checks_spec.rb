require 'spec_helper'



describe "UserTimeChecks" do

  describe "GET /user_time_checks/home" do

    it "should have the content 'Sample App'" do
      visit '/user_time_checks/home'
      expect(page).to have_content('Sample App')
    end
  
  it "should have the title 'Home'" do
      visit '/user_time_checks/home'
      expect(page).to have_title("Ruby on Rails Tutorial Sample App | Home")
    end
  end
end

describe "Check In Page" do

    it "should have the content 'Check-in time:'" do
      visit '/user_time_checks/check_in'
      expect(page).to have_content('Check-in time:')
    end
  end


#describe "User time checks" do
# subject { page }
# 
#  describe "Home page" do
#    before { visit '/user_time_checks/home' }
#    #it "should have the content 'Sample App'" do
#     # visit '/user_time_checks/home'
#      #expect(page).to have_content('Sample App')
#    #end
#    it { should have_content('Sample App')}
#  end
#end

#describe "UserTimeChecks" do
#  describe "GET /user_time_checks" do
#    it "works! (now write some real specs)" do
#      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
#      get user_time_checks_index_path
#      response.status.should be(200)
#    end
#  end
#end