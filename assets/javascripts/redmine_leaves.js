$(document).ready(function() {

$('#new_user_leave').submit(function() {
    
    var dateFrom = new Date($('#create_user_leave_selected_date_from').val());
    var dateTo = new Date($('#create_user_leave_selected_date_to').val());
    var data_working_days = $('#new_user_leave').attr('data-working-days').split(',');
    var weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    var countNonWorkingDays = 0;
    //$('#settings_working_days')
    
    for(var dayCount = 0 ; dayCount <= ((dateTo.getTime() - dateFrom.getTime())/86400000) ; dayCount++){
         
    var iterating_day = new Date(Date.parse(dateFrom)+(dayCount * 86400000));
    
        if(data_working_days.indexOf(weekDays[iterating_day.getDay()]) < 0){
            countNonWorkingDays++;
        }
    }
      if(countNonWorkingDays > 0){
    confirm('This selection includes ' + countNonWorkingDays + ' already non-working days!' );
}}
    );


//var flag_weekend = 0;
//var iterating_day = Date(params['create_user_leave']['selected_date_from']);
//    
//    while (iterating_day <= Date(params['create_user_leave']['selected_date_to'])){
//      if (Setting.plugin_redmine_leaves['working_days'].indexOf(iterating_day.getDay()) < 0){
//        flag_weekend += 1;
//	}
//        iterating_day += 1;
//    }
//    
//    if (flag_weekend > 0){
//      confirm("There are" + flag_weekend + "non-working days in your leave dates.");
//    }
    
        
    //new Date(Date.parse(a)+86400000)
    
    //dateFrom = Date(dateFrom.getTime() + (5 * 24 * 60 * 60 * 1000));  
       
    // (dateFrom.setDate(dateFrom.getDay() + 1))    
    //Date(dateFrom.setDate(dateFrom.getTime() + (1 * 24 * 60 * 60 * 1000)))
   
   
    
    
    //TODO get value of start date and end date
    //see if they non-working days are included
    //if not, then let user submit
    //if included, then warn user
    
});
