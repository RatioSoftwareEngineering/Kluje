$(document).ready(function() {
    $('.history .entry').hide();

    $('.expandable').click(function() {
	var id = $(this).attr('id');
	$('.entry.'+id).toggle();
	var icon = $(this).find('.fa')
	icon.toggleClass('fa-plus');
	icon.toggleClass('fa-minus');
    });

    $('#year-select').change(function() {
	var year = $(this).find(':selected').text();
	$('.fa-minus').toggleClass('fa-plus');
	$('.fa-minus').toggleClass('fa-minus');
	$('tr.month').hide();
	$('tr.entry').hide();
	$('tr.month.'+year).show();
    });

    var latest = $('#year-select option:last-child').val();
    $('#year-select').val(latest).change();
});
