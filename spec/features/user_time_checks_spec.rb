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
 


describe "Check In Page" do
  #Used to check the Check-in and Refresh Functionality <Check in Twice>
   before :each do
      User.stubs(:current).returns(@user)
    end
    
    it "should have the content 'Check-in time:'" do
      visit '/user_time_checks/check_in'
      expect(page).to have_content('Check-in time:')
      
    end
     it "Should Display error flash message if Check-in is Refreshed [Pressed Twice]" do
      visit("/")
      click_link("CHECK-IN")
      visit '/user_time_checks/check_in'
       expect(page).to have_content('You did not check-out last time, please check-out first')
    end
  end
  
  describe "Check Out Page" do
    
    #Used to check the Check-out and Refresh Functionality <Checkout Twice>
      before :each do
      User.stubs(:current).returns(@user)
      
      @user_time_check ||= begin
      user_time_check = UserTimeCheck.new(user_id: User.current.id, check_in_time: Time.now - 8.hours)
      user_time_check.save!
      user_time_check
      end
   
      
    end
    
    it "should have the content 'Check-Out'" do
      visit '/user_time_checks/check_out'
      expect(page).to have_content('Check-Out')
    end
    
     it "should have the content 'Check-out time:'" do
      visit '/user_time_checks/check_out'
      expect(page).to have_content('Check-out time:')
    end
    
     it "Should display error flash message if Check-out is Refreshed [Pressed Twice]" do
      visit("/")
      click_link("CHECK-OUT")
      visit '/user_time_checks/check_out'
      expect(page).to have_content('You did not check-in last time, please check-in first')
     end
     
      before do
      time_entries = TimeEntry.where(user_id: User.current.id , 
      spent_on: [@user_time_check.check_in_time, @user_time_check.check_in_time + 8.hours])
      time_entries.destroy_all
      end
    
      it "Should display error Flash meesage when Logged Time is less than Checked Time" do
      visit("/")
      click_link("CHECK-OUT")
      #visit '/user_time_checks/check_out'
      expect(page).to have_content('Your logged in  time is less than required Percentage. Log your remaining time')
      click_button('Add')
      visit '/user_time_checks/checkout_timelog_success'
    end
    
   
    
  end
  
#    describe "Check Out Time Log Success" do
#      
#      before :each do
#      User.stubs(:current).returns(@user)
#    
#      @user_time_check ||= begin
#      user_time_check = UserTimeCheck.new(user_id: User.current.id, check_in_time: Time.now - 8.hours,check_out_time: Time.now+1.hours) 
#      user_time_check.save!
#      user_time_check
#      end 
#  
#      time_entries = TimeEntry.where(user_id: User.current.id , 
#      spent_on: [@user_time_check.check_in_time, @user_time_check.check_in_time + 8.hours])
#  
#      end
#      
#      it "Should display 'Time Logged Successfully' " do
##        visit("/")
##        click_link("CHECK-OUT")
##        visit '/user_time_checks/check_out'
##        render :action => "create_time_entries"
##        click_button('Add')
##        visit '/user_time_checks/checkout_timelog_success'
#        expect(view).to render_template("/user_time_checks/checkout_timelog_success")
#        expect(page).to have_content('Time Logged Successfully')
#        
#      end
#      
#  end
      
    
  
end
