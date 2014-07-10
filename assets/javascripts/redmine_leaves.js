$(document).ready(function() {

        var weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    $('#new_user_leave').submit(function(event) {

        var dateFrom = new Date($('#create_user_leave_selected_date_from').val());
        var dateTo = new Date($('#create_user_leave_selected_date_to').val());
        var data_working_days = $('#new_user_leave').attr('data-working-days').split(',');
        var countNonWorkingDays = 0;
        var allOk = true;

        for (var dayCount = 0; dayCount <= ((dateTo.getTime() - dateFrom.getTime()) / 86400000); dayCount++) {

            var iterating_day = new Date(Date.parse(dateFrom) + (dayCount * 86400000));

            if (data_working_days.indexOf(weekDays[iterating_day.getDay()]) < 0) {
                countNonWorkingDays++;
            }
        }
        
        if (countNonWorkingDays > 0) { 
            allOk = confirm('This selection includes ' + countNonWorkingDays + ' already non-working days!');
        }
        if(allOk) {
            $('#new_user_leave').unbind('submit');
            $('#new_user_leave').submit();            
        }
        return allOk;
    }); 
    
    $('.edit_user_leave').submit(function(event) {
        
        var dateObj = new Date(Number($('#user_leave_leave_date_1i').val()), Number($('#user_leave_leave_date_2i').val())-1, Number($('#user_leave_leave_date_3i').val()));
        var data_working_days = $('.edit_user_leave').attr('data-working-days').split(',');
        var allOk = true;
        
        console.log(dateObj);
        
        if (data_working_days.indexOf(weekDays[dateObj.getDay()]) < 0) {   
            allOk = confirm('This selection is a non-working day!');
        }
        if(allOk) {
            $('.edit_user_leave').unbind('submit');
            $('.edit_user_leave').submit();            
        }
        return allOk;
    }); 
    
});
