$('.image.hidden-file').change(function(){
    $('#'+$(this).attr('id')+'-div > .grey-bg').remove();
    $('#'+$(this).attr('id')+'-div').append("<div class='grey-bg full-width full-height text-center vertical-center'><i class='glyphicon glyphicon-ok large-font full-width'></i></div>");
});

var config = {
    'countries_table': countries_table,
    'skills_table': skills_table,
    'job_country': '#commercial_job_homeowner_country_id',
    'job_city': '#commercial_job_city_id',
    'job_property_type' : '#commercial_job_property_type',
    'job_contact_time' : '#commercial_job_contact_time',
    'hid_job_category': '#commercial_job_hid_job_category_id'
};
var newJob = {
    init: function () {
        this.populateAction();
        this.populateCities();
    },

    populateCities: function() {
	$(config.job_country).on('change', function() {
	    var country_id = $(this).val();
	    var cities = config.countries_table[country_id].cities;
	    $(config.job_city).empty();
            $.each(cities, function(id, name) {
                $(config.job_city).append($('<option>', { value : id }).text(name));
            });
	});
    },

    populateAction: function(){
        $(config.job_property_type).bind({
            change: function(){
                $(config.job_property_type).removeAttr("disabled");
            }
        });

        $(config.job_property_type).bind({
            change: function(){
                $(config.job_contact_time).removeAttr("disabled");
            }
        });
    }
};


$(function() { newJob.init(); });

$(document).ready(function(){
    $('.form-control.date').datepicker({
	startDate: "now",
	format: "dd-mm-yyyy"
    });

    if(document.getElementById('commercial_job_concierge_service_true').checked) {
        var node = document.getElementById('commercial_job_concierges_service_amount');
        node.value = 20;
    }
    else if(document.getElementById('commercial_job_concierge_service_false').checked) {
        var node = document.getElementById('commercial_job_concierges_service_amount');
        node.value = 0;
    }

    $('#new_commercial_job, .edit_commercial_job').change(function(){
        selected_value = $("input[name='commercial_job[concierge_service]']:checked").val();
        if (selected_value == 'true') {
            var node = document.getElementById('commercial_job_concierges_service_amount');
            node.value = 20;
        }
        else if (selected_value == 'false') {
            var node = document.getElementById('commercial_job_concierges_service_amount');
            node.value = 0;
        }
    });


});
