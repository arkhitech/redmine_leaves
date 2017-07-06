class UserLeaveAnalyticsController < ApplicationController
  unloadable  
  
  include UserLeaveAnalyticsHelper
  def report    
    
    start_date = params[:user_leave_analytic] && params[:user_leave_analytic][:date_from].presence || Date.today.beginning_of_year
    end_date = params[:user_leave_analytic] && params[:user_leave_analytic][:date_to].presence || Date.today
    user_id       = params[:user_leave_analytic] && params[:user_leave_analytic][:selected_user] || User.current.id
    @user = User.find(user_id)
    flash_message = ""

    @bar3 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ text: "Overall Leaves Taken/Given - Bar Chart"})
      f.options[:xAxis][:categories] = ['Leave Type']
      all_leave_types.each do |leave|
        f.series(type: 'column',name: leave,data: [leaves_count_for(User.active, leave, start_date, end_date)])
      end
    end
    result = 0
    @bar3.series_data.each do |data|
      result += data[:data].first
    end    
    flash_message ="No Results Found for Overall Leaves Taken/Given<br/>" if result==0

    @pie3 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({defaultSeriesType: "pie" , margin: [50, 50, 50, 50]} )
      series = {
        type: 'pie',
        name: 'Group Leave Types',        
        data: populate_pie_chart_for_user(User.active, start_date,end_date)
      }
      f.series(series)
      f.options[:title][:text] = "Overall Leaves Taken/Given - Pie Chart"
      f.legend(layout: 'vertical',style: {left: 'auto', bottom: 'auto',right: 'auto',top: '100px'}) 
      f.plot_options(pie:{
          allowPointSelect: true, 
          cursor: "pointer" , 
          dataLabels:{
            enabled: true,
            color: "black",
            style:{
              font: "13px Trebuchet MS, Verdana, sans-serif"
            }
          }
        })
    end
    
    @bar2 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ text: "Leaves taken by Groups - Bar Chart"})
      f.options[:xAxis][:categories] = Group.all.collect{|g| g.name}
      all_leave_types.each do |leave|
        f.series(type: 'column',name: leave,data: group_leaves(leave, start_date, end_date))
      end
    end
    result = 0
    @bar2.series_data.each do |data|
      result += data[:data].first
    end    
    flash_message +="No Results Found for Leaves taken by Groups<br/>" if result==0
    
    @pie2 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({defaultSeriesType: "pie" , margin: [50, 50, 50, 50]} )
      series = {
        type: 'pie',
        name: 'Group Leaves',
        data: populate_pie_chart_for_group(start_date,end_date)
      }
      f.series(series)
      f.options[:title][:text] = "Leaves taken by Groups - Pie Chart"
      f.legend(layout: 'vertical',style: {left: 'auto', bottom: 'auto',right: 'auto',top: '100px'}) 
      f.plot_options(pie:{
          allowPointSelect: true, 
          cursor: "pointer", 
          dataLabels:{
            enabled: true,
            color: "black",
            style:{
              font: "13px Trebuchet MS, Verdana, sans-serif"
            }
          }
        })
    end
    
    @bar1 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ text: "Type of Leaves taken by #{@user.name} - Bar Chart"})
      f.options[:xAxis][:categories] = ['Leave Type']
      
      all_leave_types.each do |leave|
        f.series(type: 'column',name: leave,data: [leaves_count_for(@user.id, leave, start_date, end_date)])
      end
    end
    result = 0
    @bar1.series_data.each do |data|
      result += data[:data].first
    end    
    flash_message +="No Results Found for Type of Leaves taken by #{@user.name}" if result==0
    
    @pie1 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({defaultSeriesType: "pie" , margin: [50, 50, 50, 50]} )
      series = {
        type: 'pie',
        name: 'User Leave Types',
        data: populate_pie_chart_for_user(@user.id, start_date,end_date)
      }
      f.series(series)
      f.options[:title][:text] = "Type of Leaves taken by #{@user.name} - Pie Chart"
      f.legend(layout: 'vertical',style: {left: 'auto', bottom: 'auto',right: 'auto',top: '100px'}) 
      f.plot_options(pie:{
          allowPointSelect: true, 
          cursor: "pointer" , 
          dataLabels:{
            enabled: true,
            color: "black",
            style:{
              font: "13px Trebuchet MS, Verdana, sans-serif"
            }
          }
        })
    end
    flash.now[:warning] = flash_message unless flash_message.blank?
  end
end
