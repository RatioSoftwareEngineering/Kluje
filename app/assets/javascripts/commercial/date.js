$('.image.hidden-file').change(function(){
    $('#'+$(this).attr('id')+'-div > .grey-bg').remove();
    $('#'+$(this).attr('id')+'-div').append("<div class='grey-bg full-width full-height text-center vertical-center'><i class='glyphicon glyphicon-ok large-font full-width'></i></div>");
});


$(document).ready(function(){
    $('.form-control.date').datepicker({
        // startDate: "now",
        format: "dd-mm-yyyy"
    });

});
