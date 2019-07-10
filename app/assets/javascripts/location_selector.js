$(document).ready(function(){
    $('.locale-menu').click(function (e) {
	e.stopPropagation();
    });

    $('#country-selector').change(function(e) {
	var country_id = this.value;
	var cities_selector = $('#city-selector');
	var cities = countries_table[country_id]['cities'];
	cities_selector.empty();
	$.each(cities, function(id, name) {
	    cities_selector.append($('<option>', { value: id }).text(name));
	});
    });

    $('#locale-cancel').click(function(e) {
	$('#country-selector').val(locale['country_id']);
	$('#country-selector').change();
	$('#city-selector').val(locale['city_id']);
	$('input:radio').prop('checked', false);
	$('#locale_'+locale['lang']).prop('checked', true);
	$("body").click();
    });
});
