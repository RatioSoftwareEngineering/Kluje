$(document).ready(function(){
    $('.form-control.date').datepicker({
        startDate: "now",
        format: "dd-mm-yyyy"
    });
    $('.form-control.time').timepicker({
        timeFormat: 'HH:mm:ss',
        minTime: '11:45:00',
        maxHour: 20,
        maxMinutes: 30,
        startTime: new Date(0,0,0,15,0,0),
        interval: 15
    });
    $('.dateselect-time').timepicker({
        timeFormat: 'HH:mm:ss',
        minTime: '11:45:00',
        maxHour: 20,
        maxMinutes: 30,
        startTime: new Date(0,0,0,15,0,0),
        interval: 15
    });
});
