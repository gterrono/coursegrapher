(function() {
  google.load('visualization', '1', {'packages':['motionchart']});
  google.setOnLoadCallback(drawChart);
  function drawChart() {
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Major');
		data.addColumn('date', 'Date');
    data.addColumn('number', 'Instructor Quality');
    data.addColumn('number', 'Difficulty');
    data.addColumn('number', 'Course Quality');
    data.addColumn('number', 'Ability to Stimulate Interest');
    data.addColumn('number', 'Access to Instructor');
    data.addColumn('number', 'Amount Learned');
    data.addColumn('number', 'Amount of Work');
    data.addColumn('number', 'Instructor\'s Communication');
    data.addColumn('number', 'Recommended for Majors');
    data.addColumn('number', 'Recommended for Non-Majors');
    data.addColumn('number', 'Number of Reviews');
    var rows = JSON.parse($("#rows").html());
    var date = new Date(2012, 0, 1);
    for(var index in rows) {
      rows[index].splice(1, 0, date);
    }
    console.log(rows);
    data.addRows(rows);
    var chart = new google.visualization.MotionChart(document.getElementById('chart_div'));
    var options = {};
    var state = {
      "showTrails":true,
      "playDuration":15000,
      "iconType":"BUBBLE",
      "xLambda":1,
      "yZoomedDataMin":null,
      "xZoomedDataMin":null,
      "yLambda":1,
      "yZoomedIn":false,
      "nonSelectedAlpha":0.4,
      "orderedByY":false,
      "uniColorForNonSelected":false,
      "xZoomedIn":false,
      "time":"notime",
      "yAxisOption":"3",
      "xZoomedDataMax":null,
      "dimensions":{"iconDimensions":["dim0"]},
      "sizeOption":"12",
      "duration":{"multiplier":1,"timeUnit":"D"},
      "yZoomedDataMax":null,
      "xAxisOption":"2",
      "iconKeySettings":[],
      "orderedByX":false,
      "colorOption":"4"
    };
    options['state'] = JSON.stringify(state);
    options['showYScalePicker'] = false;
    options['showXScalePicker'] = false;
    options['width'] = 950;
    options['height'] = 450;
    chart.draw(data, options);

    google.visualization.events.addListener(chart, 'statechange', someFunc);
    function someFunc(e) {
      if (chart.getState()!=null) {
        var state = JSON.parse(chart.getState());
        var longTitle = state.iconKeySettings[0].key.dim0;
        var pattern = /[(]([\w]{1,5})[)]$/;
        var match = longTitle.match(pattern);
        var dept = match[1];
        window.location = '/course/'+dept;
      }
    }
  }
})();
