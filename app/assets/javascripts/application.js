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
//= require js.cookie
//= require jquery.validate
//= require selectize

var switch_value = function() {
    var old_value = $(this).text();
    var new_value = $(this).data('value');
    $(this).text(new_value);
    $(this).data('value', old_value);
};

var getUrlParameter = function getUrlParameter(sParam) {
  var sPageURL = decodeURIComponent(window.location.search.substring(1)),
      sURLVariables = sPageURL.split('&'),
      sParameterName,
      i;

  for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] === sParam) {
          return sParameterName[1] === undefined ? true : sParameterName[1];
      }
  }
};

String.prototype.insert = function (index, string) {
  if (index > 0)
    return this.substring(0, index) + string + this.substring(index, this.length);
  else
    return string + this;
};

$(document).ready(function(){
    // modal field focus
    $('#signin').on('shown.bs.modal', function(e) { $('#account_email').focus() });

    $("body").tooltip({
        selector: "[rel=tooltip], [rel='tooltip nofollow']",
        trigger: 'hover',
        placement: 'top'
    });

    $('.mouseover').mouseover(switch_value);
    $('.mouseover').mouseout(switch_value);
});
