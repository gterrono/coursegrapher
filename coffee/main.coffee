google.load('visualization', '1', {'packages':['motionchart']})

window.drawChart = () ->
  hash = window.location.hash
  data = new google.visualization.DataTable()
  data.addColumn('string', 'Major')
  data.addColumn('date', 'Date')
  data.addColumn('number', 'Instructor Quality')
  data.addColumn('number', 'Difficulty')
  data.addColumn('number', 'Course Quality')
  data.addColumn('number', 'Ability to Stimulate Interest')
  data.addColumn('number', 'Access to Instructor')
  data.addColumn('number', 'Amount Learned')
  data.addColumn('number', 'Amount of Work')
  data.addColumn('number', 'Instructor\'s Communication')
  data.addColumn('number', 'Recommended for Majors')
  data.addColumn('number', 'Recommended for Non-Majors')
  data.addColumn('number', 'Number of Reviews')
  dept_name = if hash.length > 1 then hash.substr(1) else ''
  $.get "https://coursegrapher.firebaseio.com/#{dept_name}.json", (json) ->
    console.log 'got data'
    row = (id, dept) ->
      return null unless dept.averages?
      get = (field) -> dept.averages[field] or 0
      name = if dept.name? then "#{dept.name} (#{id})" else "#{dept_name} #{id}"
      [
        name
        new Date(2011, 0, 1)
        get('rInstructorQuality')
        get('rDifficulty')
        get('rCourseQuality')
        get('rStimulateInterest')
        get('rInstructorAccess')
        get('rAmountLearned')
        get('rWorkRequired')
        get('rCommAbility')
        get('rRecommendMajor')
        get('rRecommendNonMajor')
        dept.num or 1
      ]
    a = (row(k, v) for k, v of json)
    data.addRows(_.filter(a, _.isArray))
    window.chart = new google.visualization.MotionChart(document.getElementById('chart_div'))
    options = {}
    options['state'] =
      '{"showTrails":true,"playDuration":15000,"iconType":"BUBBLE","xLambda":1,"yZoomedDataMin":null,"xZoomedDataMin":null,"yLambda":1,"yZoomedIn":false,"nonSelectedAlpha":0.4,"orderedByY":false,"uniColorForNonSelected":false,"xZoomedIn":false,"time":"notime","yAxisOption":"3","xZoomedDataMax":null,"dimensions":{"iconDimensions":["dim0"]},"sizeOption":' + (if dept_name then '"_UNISIZE"' else '"12"') + ',"duration":{"multiplier":1,"timeUnit":"D"},"yZoomedDataMax":null,"xAxisOption":"2","iconKeySettings":[],"orderedByX":false,"colorOption":"4"};'

    options['showYScalePicker'] = false
    options['showXScalePicker'] = false
    options['width'] = 950
    options['height'] = 450
    chart.draw(data, options)

    unless window.location.hash
      google.visualization.events.addListener(chart, 'statechange', (e) ->
        return if chart.getState() == null
        state = JSON.parse(chart.getState())
        longtitle = state.iconKeySettings[0].key.dim0
        pat = /[(]([\w]{1,5})[)]$/
        m = longtitle.match(pat)
        dept = m[1]
        window.location = "##{dept}")
    console.log 'drawn'

fix_headline = () ->
  hash = window.location.hash
  if hash.length > 1
    $('#graph-title').text("Courses in #{hash.substr(1)}")
    $extra = $('#extra-info')
    $extra.text('Click and drag over an area to zoom in (hit enter after clicking zoom)')
    $extra.after('<span id="back" style="float:right;padding-top:20px" class="little"><a href="#">back to depts</a></span>')
  else
    $('#graph-title').text('Departments at Penn')
    $('#extra-info').text('Clicking on a bubble will take you to the course page for that department')
    $('#back').remove()

fix_headline()

window.onhashchange = () ->
  fix_headline()
  drawChart()

google.setOnLoadCallback(drawChart)
