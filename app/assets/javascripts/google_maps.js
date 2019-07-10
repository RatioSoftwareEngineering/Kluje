function initialize() {
    var data = $('#map-canvas').data();
    var coords = { lat: data['lat'], lng: data['lng'] };
    var mapOptions = {
	center: coords,
	zoom: data['zoom']
    }
    var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    marker = new google.maps.Marker({
	position: coords,
	map: map,
	title: data['title']
    });
};

$(document).ready(function() {
    google.maps.event.addDomListener(window, 'load', initialize);
});
