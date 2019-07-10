var config = {
    'skills_table': skills_table,
    'selectedSkill': '#job_skill_id',
    'selectedJobCategory': '#job_job_category_id',
}

var Homeowner = {
    select_skill: {
        init: function (){
            this.populate_job_categories();
            this.select_job_category();
        },
        populate_job_categories: function() {
            $(config.selectedSkill).bind({
                change: function() {
		    var blank = $(config.selectedJobCategory)[0].options[0].text;
		    if (blank[0] != '-') { blank = "---"+blank+"---"; }
                    var skill_id = $(this).val();
                    var job_categories = config.skills_table[skill_id].job_categories;
                    $(config.selectedJobCategory).empty();
                    $(config.selectedJobCategory).append($('<option>', { value : "" }).text(blank));
                    $.each(job_categories, function(id, name) {
                        $(config.selectedJobCategory)
                            .append($('<option>', { value : id })
                            .text(name));
                    })
                    $(config.selectedJobCategory).removeAttr('disabled');
                }
            })
        },
        select_job_category: function() {
            var skill_id = $(config.selectedSkill).val();
            if (skill_id && skill_id.length > 0) {
                $(config.selectedSkill).change();
            }
        },
    }
}

$(function() { Homeowner.select_skill.init(); });

$(document).ready(function() {

    $('.toggle-rating').click(function() {
        var id = $(this).attr('id').substr(4);
        $(['rating', 'hide', 'show']).each(function(i,v) {
            $('#'+v+id).toggle();
        });
    });
});

