$.fn.hiddenParents = function(){
  var $self = this,
      $parent = $self.parent();

  while ($parent.length && !$parent.is("html")){
    if ($parent.css("display") == "none"){
      return $parent;
    }
    $parent = $parent.parent();
  }

  // empty jquery
  return $([]);
};

var findHiddenParent = function(container) {
  if (container.css('display') == 'none' || container.length == 0) {
    return container;
  } else {
    return findHiddenParent(container.parent());
  }
};

function drawColumnChart(data_container, raw_data, options) {
  var data = google.visualization.arrayToDataTable(raw_data);
  var container = document.getElementById(data_container);
  var chart = new google.visualization.ColumnChart(container);

  smartDraw(chart, data, options, container);
}

function drawLineChart(data_container, raw_data, options) {
  var data = google.visualization.arrayToDataTable(raw_data);
  var container = document.getElementById(data_container);
  var chart = new google.visualization.LineChart(container);

  smartDraw(chart, data, options, container);
}

var smartDraw = function(chart, data, options, container) {
  var parent = $(container).hiddenParents();
  if (parent.length) {
    parent.show();
  }

  chart.draw(data, options);

  if (parent.length) {
    parent.hide();
  }
};
