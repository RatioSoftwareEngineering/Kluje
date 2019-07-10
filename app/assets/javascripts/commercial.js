// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require bootstrapValidator.min
//= require location_selector
//= require bootstrap-datepicker/core
//= require bootstrap-timepicker
$(document).ready(function() {

    $('.toggle-rating').click(function() {
        var id = $(this).attr('id').substr(4);
        $(['rating', 'hide', 'show']).each(function(i,v) {
            $('#'+v+id).toggle();
        });
    });

    $('.toggle-meeting').click(function() {
        var id = $(this).attr('id').substr(5);
        $(['meeting', 'hidem', 'showm']).each(function(i,v) {
            $('#'+v+id).toggle();
        });
    });

    $('.toggle-clarification').click(function() {
        var id = $(this).attr('id').substr(5);
        $(['clarification', 'hidem', 'showm']).each(function(i,v) {
            $('#'+v+id).toggle();
        });
    });

    $('.toggle-details').click(function() {
        var id = $(this).attr('id').substr(4);
        $(['details', 'hide', 'show']).each(function(i,v) {
            $('#'+v+id).toggle();
        });
    });
    $('.toggle-invoice').click(function() {
        var id = $(this).attr('id').substr(4);
        $(['invoice', 'hide', 'show']).each(function(i,v) {
            $('#'+v+id).toggle();
        });
    });
});