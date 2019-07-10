$('#residential_job_homeowner_attributes_country_id').change(function() {
    var postal_codes = $(this).find(':selected').data('postal-codes');
    var group = $('#postal_code_group');
    var field = $('#residential_job_postal_code');

    if (postal_codes) {
	field.attr('required', 'true');
	group.removeClass('hidden');
	group.show();
    } else {
	field.removeAttr('required');
	group.hide();
    }
});

$('.image.hidden-file').change(function(){
    $('#'+$(this).attr('id')+'-div > .grey-bg').remove();
    $('#'+$(this).attr('id')+'-div').append("<div class='grey-bg full-width full-height text-center vertical-center'><i class='glyphicon glyphicon-ok large-font full-width'></i></div>");
});

$("#btnGetQuote").click(function(event){
    event.preventDefault();
    $('.inputDisabled').prop("disabled", false);
});

var config = {
    'countries_table': countries_table,
    'skills_table': skills_table,
    'job_country': '#residential_job_homeowner_country_id',
    'job_city': '#residential_job_city_id',
    'job_skill' : '#residential_job_skill_id',
    'selectedJobCategory': '#residential_job_job_category_id',
    'budgets': '#residential_job_budget_id',
    'selectedSkill' : '#residential_job_skill_id',
    "job_availability" : "#residential_job_availability_id",
    "job_property_type" : "#residential_job_property_type",
    "job_contact_time" : "#residential_job_contact_time",
    "hid_job_category":"#residential_job_hid_job_category_id",
    "hid_budget":" #residential_job_hid_budget_id",
    "job_budget" : "#residential_job_budget_id"
};
var newJob = {
    init: function(){
	this.populateJobCategory();
	this.populateBudgetsByCategory();
        this.populateAction();
	this.populateCities();
        this.disableSelectBox();
        $(config.selectedJobCategory).removeAttr('disabled');
        if($(config.hid_job_category).val() != null){
            $(config.selectedJobCategory).val($(config.hid_job_category).val());
        }

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
    populateJobCategory: function(){
        $(document).ready(function(){
            var skill_id = $(config.job_skill).val();
            if(skill_id) {
		var blank = $(config.selectedJobCategory)[0].options[0].text;
		if (blank[0] != '-') { blank = "---"+blank+"---"; }
                var job_categories = config.skills_table[skill_id].job_categories;
                $(config.selectedJobCategory).empty();
                $(config.selectedJobCategory).append($('<option>', { value : "" }).text(blank));
                $.each(job_categories, function(id, name) {
                    $(config.selectedJobCategory)
                        .append($('<option>', { value : id })
				.text(name));
                });
                    $(config.selectedJobCategory).removeAttr('disabled');
                $(config.selectedJobCategory).val($(config.hid_job_category).val());
            }

            var job_category_id = $(config.selectedJobCategory).val()
            if(job_category_id) {
                $.get('/en/budgets?job_category_id='+job_category_id,function(budgets) {
		    var blank = $(config.budgets)[0].options[0].text;
		    if (blank[0] != '-') { blank = "---"+blank+"---"; }
                    jBudgets = jQuery.parseJSON(budgets);
                    $(config.budgets).empty();
                    $(config.budgets).append($('<option>', { value : "" }).text(blank));
                    $.each(jBudgets, function(index) {
                        $.each(jBudgets[index],function(index,budget){
                            $(config.budgets).append($('<option>', { value : budget['id'] }).text(budget['range']));
                        });
                    });
			$(config.job_budget).val($(config.hid_budget).val());
                });
                $(config.budgets).removeAttr('disabled');
            }

            if($(config.budgets).val() != ' '){
                $(config.job_availability).removeAttr('disabled');
            }

            if($(config.job_availability).val() != ' '){
                $(config.job_property_type).removeAttr('disabled');
            }

            if($(config.mobile_number).val() != ' '){
                $(config.job_contact_time).removeAttr('disabled');
            }
        });
    },

    populateBudgetsByCategory: function() {
        $(config.selectedJobCategory).bind({
            change: function() {
                var jobCategoryId = $(this).val();
                var jobCountryId = $(config.job_country).val();
                $.get('/en/budgets?job_category_id='+jobCategoryId+'&country_id='+jobCountryId, function(budgets) {
		    var blank = $(config.budgets)[0].options[0].text;
		    if (blank[0] != '-') { blank = "---"+blank+"---"; }
                    jBudgets = budgets;
                    $(config.budgets).empty();
                    $(config.budgets).append($('<option>', { value : "" }).text(blank));
                    $.each(jBudgets, function(index) {
                        $.each(jBudgets[index],function(index,budget){
                            $(config.budgets).append($('<option>', { value : budget['id'] }).text(budget['range']));
                        });
                    })
			});
                $(config.budgets).removeAttr('disabled');
            }
        })
    },
    populateAction: function(){
        $(config.budgets).bind({
            change: function(){
                $(config.budgets).removeAttr('disabled');
                $(config.job_availability).removeAttr("disabled");
            }
        });

        $(config.job_availability).bind({
            change: function(){
                $(config.job_availability).removeAttr("disabled");
            }
        });

        $(config.job_availability).bind({
            change: function(){
                $(config.job_property_type).removeAttr("disabled");
            }
        });

        $(config.job_property_type).bind({
            change: function(){
                $(config.job_contact_time).removeAttr("disabled");
            }
        })
    },
    disableSelectBox: function(){
        $(config.selectedJobCategory).attr('disabled','disabled');
        $(config.budgets).attr('disabled','disabled');
        $(config.job_availability).attr("disabled",'disabled');
        $(config.job_property_type).attr('disabled','disabled');
        $(config.job_contact_time).attr("disabled",'disabled');
    }
};


$(function() { newJob.init(); });
