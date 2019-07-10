var singapore_only = function() {
    var selected_country = $('#account_country_id option:selected').text();
    if (selected_country == 'Singapore') {
	$('.singapore_only').show();
    } else {
	$('.singapore_only').hide();
    }
};

$(document).ready(function() {
    $('#account_country_id').change( singapore_only );
    singapore_only();
});
