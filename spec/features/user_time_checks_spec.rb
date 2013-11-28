require 'spec_helper'



describe "UserTimeChecks" do
  #works for all users to get them login
 before (:all) do
   @user=User.find_by_login('testuser')
   @user ||= begin
      user = User.new(firstname: "test", lastname: "user", mail: "test@user.com")
      user.login = "testuser"
      user.password = "testuser"
      user.save!
      user
    end
     
 end
 
  describe "GET /user_time_checks/home" do
    before :each do
      User.stubs(:current).returns(@user)
    end
    
    it "should have the content 'Sample App'" do
      visit '/user_time_checks/home'
      expect(page).to have_content('Sample App')
    end
  
  it "should have the title 'Home'" do
      visit '/user_time_checks/home'
      expect(page).to have_title("Ruby on Rails Tutorial Sample App | Home")
    end
  end


describe "Check In Page" do

   before :each do
      User.stubs(:current).returns(@user)
    end
    
    it "should have the content 'Check-in time:'" do
      visit '/user_time_checks/check_in'
      expect(page).to have_content('Check-in time:')
      
    end
     it "Should Display error flash message if reloaded'" do
      visit("/")
      click_link("CHECK-IN")
      visit '/user_time_checks/check_in'
#      visit '/user_time_checks/check_in'
#      expect(page).to have_content('Check-in time:')
       expect(page).to have_content('You did not check-out last time, please check-out first')
       #redirect_to check_in_url
    end
  end
  
  describe "Check Out Page" do
    
    
      before :each do
      User.stubs(:current).returns(@user)
      
      #@user_time_check=UserTimeCheck.find_by_user_id(User.current.id)
      @user_time_check ||= begin
      user_time_check = UserTimeCheck.new(user_id: User.current.id, check_in_time: "2013-11-20 11:25:57")
#      user_time_check.check_out_time="2013-11-20 11:27:57" 
      user_time_check.save!
      user_time_check
      end
      
      #UserTimeCheck.stubs(:current).returns(@user_time_check)
      
    end
    
    it "should have the content 'Check-Out'" do
      visit '/user_time_checks/check_out'
      expect(page).to have_content('Check-Out')
    end
    
     it "should have the content 'Check-out time:'" do
      visit '/user_time_checks/check_out'
      expect(page).to have_content('Check-out time:')
    end
    
     it "Should Display error flash message if reloaded'" do
      visit("/")
      click_link("CHECK-OUT")
      visit '/user_time_checks/check_out'
      #context "when logged_time not complete"
      #let() {}
      expect(page).to have_content('Your logged in  time is less than required Percentage. Log your remaining time')
      
     # expect(page).to have_content('You did not check-in last time, please check-in first')
      #redirect_to check_in_url
    end
  end
  
end
