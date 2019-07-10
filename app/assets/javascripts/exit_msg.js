function exit_msg() {
    var total_len = 0;
    var min_len = 25;
    $(':text').each( function( ) {
	el_len = this.value.replace(/ /g,'').length;
	total_len += el_len;
	if (el_len < min_len) {
	    min_len = el_len;
	}
    });
    if (min_len == 0 && total_len > 10)
	return "You haven’t finished signing up for your account. Are you sure you don't want your FREE account?";
}

function no_msg() {
}

$(document).ready(function() {
    window.onbeforeunload = exit_msg;
    $('form').submit(function(){ window.onbeforeunload = no_msg; });
});
