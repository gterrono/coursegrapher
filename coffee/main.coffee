google.load('visualization', '1', {'packages':['motionchart']})

# alex's logging function that he likes to use.
l = (message, objs...) ->
  now = new Date()
  hours = now.getHours()
  mins = now.getMinutes()
  secs = now.getSeconds()
  console.log(["#{ hours }:#{ mins }.#{ secs }", message, objs...])
  return

window.drawChart = () ->

  # set up basic google datatable
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

  # get dept name if its there
  hash = window.location.hash.toUpperCase()
  dept_name = if hash.length > 1 then hash.substr(1) else ''

  # get pre-computed data from firebase, put in chart.
  $.get "https://coursegrapher.firebaseio.com/#{dept_name}.json", (json) ->
    l 'got data', json


    row_from_firebase = (id, dept) ->
      return null unless dept.averages?

      get = (field) ->
        n = dept.averages[field] or 0
        parseFloat n.toFixed(2)

      name = if dept.name? then "#{dept.name} (#{id})" else "#{dept_name} #{id}"

      [
        name
        new Date(2014, 0, 1)
        get('rInstructorQuality')
        get('rDifficulty')# or null  # filters out the zeroes, I think
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

    # turn firebase into arrays using above func
    a = (row_from_firebase(k, v) for k, v of json)
    data.addRows(_.filter(a, _.isArray))

    # set up options, draw chart.
    chart_div = document.getElementById('chart_div')
    window.chart = new google.visualization.MotionChart(chart_div)
    options =
      showYScalePicker: false
      showXScalePicker: false
      width: 950
      height: 450
      state:
        "showTrails":true
        "playDuration":15000
        "iconType":"BUBBLE"
        "xLambda":1
        "yZoomedDataMin":null
        "xZoomedDataMin":null
        "yLambda":1
        "yZoomedIn":false
        "nonSelectedAlpha":0.4
        "orderedByY":false
        "uniColorForNonSelected":false
        "xZoomedIn":false,
        "time":"notime",
        "yAxisOption":"3",
        "xZoomedDataMax":4,
        "dimensions":{"iconDimensions":["dim0"]},
        "sizeOption": if dept_name then "_UNISIZE" else 12
        "duration":{"multiplier":1,"timeUnit":"D"},
        "yZoomedDataMax":null
        "xAxisOption":"2"
        "iconKeySettings":[]
        "orderedByX":false
        "colorOption":"4"

    chart.draw(data, options)

    unless window.location.hash
      google.visualization.events.addListener chart, 'statechange', (e) ->
        return if chart.getState() == null

        # when someone clicks a bubble,
        # parse what they clicked
        # and take them to that dept.
        state = JSON.parse(chart.getState())
        longtitle = state.iconKeySettings[0].key.dim0
        pat = /[(]([\w]{1,5})[)]$/
        m = longtitle.match(pat)
        dept = m[1]
        window.location = "##{dept}"

    l 'drew chart'

fix_headline = () ->
  hash = window.location.hash
  if hash.length > 1
    dept_name = hash.substr(1)
    $('#graph-title').text("Courses in #{dept_name}")
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
