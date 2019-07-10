var switchToInput = function() {
    var self = $(this);

    var classes = $(this).attr('class');
    var data = $(this).data();
    var id = $(this).attr('id');
    var text = $(this).text();

    var input = $('<textarea>', {val: text, width: '100%', height: '100px', type: 'text', class: classes, id: id, data: data});

    $(this).replaceWith(input);

    input.on('blur', switchToSpan);
    input.on('keyup', function(e) {
	if (e.keyCode == '13') {
	    switchToSpan.call(this);
	}
	if (e.keyCode == '27') {
	    input.replaceWith(self);
	    self.click(switchToInput);
	}

    });
    input.select();
};

var switchToSpan = function() {
    var classes = $(this).attr('class');
    var id = $(this).attr('id');
    var data = $(this).data();
    var text = $(this).val();

    var span = $('<span>', {text: text, class: classes, id: id, data: data});
    $(this).replaceWith(span);
    span.click(switchToInput);

    var csrfParam = $('meta[name=csrf-param]').attr("content");
    var csrfToken = $('meta[name=csrf-token]').attr("content");

    var params = {};
    params[id] = text;
    // params[csrfParam] = csrfToken;

    $.ajax({
	url: span.data('url'),
	data: params,
	method: 'POST'
    });
}

$(document).ready(function() {
    $('.autoupload').change(function() {
	var form = $(this).closest('form');
	form.submit();
    });

    $('.editable').click(switchToInput);

    $('.inline_edit').click(function() {
	var id = $(this).attr('id')
	id = id.substr(1,id.length-6);
	var span = $('#'+id+'.editable');
	switchToInput.call(span);
	return false;
	// var text = span.text();
	// var new_text = prompt("Enter description", text);
	// console.log(span);

    });
});
