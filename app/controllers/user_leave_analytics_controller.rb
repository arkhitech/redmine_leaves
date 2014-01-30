class UserLeaveAnalyticsController < ApplicationController
  unloadable  
  
  include UserLeaveAnalyticsHelper
  
  def report
    if params[:user_leave_analytic]
      start_date = params[:user_leave_analytic][:date_from]
      end_date   = params[:user_leave_analytic][:date_to]
      user       = params[:user_leave_analytic][:selected_user]
      if params[:user_leave_analytic][:date_from] > params[:user_leave_analytic][:date_to]
        flash.now[:error] = "'Date From' cannot be greater than 'Date To'"
      end
      if params[:user_leave_analytic][:date_from].blank? || params[:user_leave_analytic][:date_to].blank?
        flash.now[:error] = "Date Field(s) cannot be empty"
      end
    else
      start_date = Date.today - 1.year
      end_date   = Date.today
      user       = User.current.id
    end
        
    flash_message = ""
    
    @bar1 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"Overall Leaves Taken/Given - Bar Chart"})
      f.options[:xAxis][:categories] = ['Leave Type']
      all_leave_types.each do |leave|
        f.series(:type=> 'column',:name=> leave,:data=> [leaves_count_for(User.active, leave, start_date, end_date)])
      end
    end
    result = 0
    @bar1.series_data.each do |data|
      result += data[:data].first
    end    
    flash_message ="No Results Found for Overall Leaves Taken/Given<br/>" if result==0

    @pie1 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 50, 50, 50]} )
      series = {
        :type=> 'pie',
        :name=> 'Leave Types',        
        :data=> populate_pie_chart_for_user(User.active, start_date,end_date)
      }
      f.series(series)
      f.options[:title][:text] = "Overall Leaves Taken/Given - Pie Chart"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> 'auto',:top=> '100px'}) 
      f.plot_options(:pie=>{
          :allowPointSelect=>true, 
          :cursor=>"pointer" , 
          :dataLabels=>{
            :enabled=>true,
            :color=>"black",
            :style=>{
              :font=>"13px Trebuchet MS, Verdana, sans-serif"
            }
          }
        })
    end
    
    @bar2 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"Leaves taken by Groups - Bar Chart"})
      f.options[:xAxis][:categories] = Group.all.collect{|g| g.name}
      all_leave_types.each do |leave|
        f.series(:type=> 'column',:name=> leave,:data=> group_leaves(leave, start_date, end_date))
      end
    end
    result = 0
    @bar2.series_data.each do |data|
      result += data[:data].first
    end    
    flash_message +="No Results Found for Leaves taken by Groups<br/>" if result==0
    
    @pie2 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 50, 50, 50]} )
      series = {
        :type=> 'pie',
        :name=> 'Group Leaves',
        :data=> populate_pie_chart_for_group(start_date,end_date)
      }
      f.series(series)
      f.options[:title][:text] = "Leaves taken by Groups - Pie Chart"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> 'auto',:top=> '100px'}) 
      f.plot_options(:pie=>{
          :allowPointSelect=>true, 
          :cursor=>"pointer" , 
          :dataLabels=>{
            :enabled=>true,
            :color=>"black",
            :style=>{
              :font=>"13px Trebuchet MS, Verdana, sans-serif"
            }
          }
        })
    end
    
    @bar3 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"Type of Leaves taken by #{User.find(user).name} - Bar Chart"})
      f.options[:xAxis][:categories] = ['Leave Type']
      
      all_leave_types.each do |leave|
        f.series(:type=> 'column',:name=> leave,:data=> [leaves_count_for(user, leave, start_date, end_date)])
      end
    end
    result = 0
    @bar3.series_data.each do |data|
      result += data[:data].first
    end    
    flash_message +="No Results Found for Type of Leaves taken by #{User.find(user).name}" if result==0
    
    @pie3 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 50, 50, 50]} )
      series = {
        :type=> 'pie',
        :name=> 'Group Leaves',
        :data=> populate_pie_chart_for_user(user, start_date,end_date)
      }
      f.series(series)
      f.options[:title][:text] = "Type of Leaves taken by #{User.find(user).name} - Pie Chart"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> 'auto',:top=> '100px'}) 
      f.plot_options(:pie=>{
          :allowPointSelect=>true, 
          :cursor=>"pointer" , 
          :dataLabels=>{
            :enabled=>true,
            :color=>"black",
            :style=>{
              :font=>"13px Trebuchet MS, Verdana, sans-serif"
            }
          }
        })
    end
    flash.now[:warning] = flash_message unless flash_message.blank?
  end
end
