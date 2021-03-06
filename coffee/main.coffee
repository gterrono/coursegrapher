google.load('visualization', '1', {'packages':['corechart']})

# alex's logging function that he likes to use.
l = (message, objs...) ->
  now = new Date()
  hours = now.getHours()
  mins = now.getMinutes()
  secs = now.getSeconds()
  console.log(["#{ hours }:#{ mins }.#{ secs }", message, objs...])
  return

window.drawChart = (only_offered) ->
  # get dept name if its there
  hash = window.location.hash.toUpperCase()
  dept_name = if hash.length > 1 then hash.substr(1) else ''
  root_view = if dept_name then false else true

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
  if root_view
    data.addColumn('number', '# of Courses Offered This Semester')
  else
    data.addColumn('string', 'Offerred this Semester')

  firebase_key = dept_name or 'depts'
  # get pre-computed data from firebase, put in chart.
  $.get "https://coursegrapher.firebaseio.com/#{firebase_key}.json", (json) ->
    l 'got data', json

    row_from_firebase = (id, dept) ->
      return null unless dept.averages?

      if not root_view and only_offered == true and not dept.offered
        return null

      get = (field) ->
        n = dept.averages[field] or 0
        parseFloat n.toFixed(2)

      name = if dept.num? then "#{dept.name} (#{id})" else "[#{dept_name} #{id}] #{dept.name}"

      if dept.num < 20
        l 'skipping dept because to small', name, dept.num
        return null

      return [
        name
        new Date()
        get('rInstructorQuality')
        get('rDifficulty') or null  # filters out the zeroes, I think
        get('rCourseQuality')
        get('rStimulateInterest')
        get('rInstructorAccess')
        get('rAmountLearned')
        get('rWorkRequired')
        get('rCommAbility')
        get('rRecommendMajor')
        get('rRecommendNonMajor')
        if root_view then dept.course_count else dept.offered.toString()
      ]

    # turn firebase into arrays using above func
    a = (row_from_firebase(k, v) for k, v of json)
    data.addRows(_.filter(a, _.isArray))

    # set up options, draw chart.
    chart_div = document.getElementById('chart_div')
    window.chart = new google.visualization.MotionChart(chart_div)
    width = $('#main_container').width()
    height = Math.min(width / 2, $(window).height() - 100)
    options =
      showYScalePicker: false
      showXScalePicker: false
      showChartButtons: false
      width: width
      height: height
      state: '{"showTrails":false,"playDuration":15000,"iconType":"BUBBLE","xLambda":1,"yZoomedDataMin":null,"xZoomedDataMin":null,"yLambda":1,"yZoomedIn":false,"nonSelectedAlpha":0.4,"orderedByY":false,"uniColorForNonSelected":false,"xZoomedIn":false,"time":"notime","yAxisOption":"3","xZoomedDataMax":null,"dimensions":{"iconDimensions":["dim0"]},"sizeOption":' + (if dept_name then '"_UNISIZE"' else '"12"') + ',"duration":{"multiplier":1,"timeUnit":"D"},"yZoomedDataMax":null,"xAxisOption":"4","iconKeySettings":[],"orderedByX":false,"colorOption":"2"};'

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
    $extra.after('<div id="only-offered-checkbox" style="float:right;padding-top:20px;padding-right:20px;font-size:17px"><input type="checkbox" name="only-offered" id="only-offered"><label for="only-offered" style="padding-left:5px">Display offered courses only</label></div>')
    $extra.after('<span id="back" style="float:right;padding-top:20px" class="little"><a href="#">back to depts</a></span>')
  else
    $('#graph-title').text('Departments at Penn')
    $('#extra-info').text('Clicking on a bubble will take you to the course page for that department')
    $('#only-offered-checkbox').remove()
    $('#back').remove()

fix_headline()

window.onhashchange = () ->
  fix_headline()
  drawChart()

google.setOnLoadCallback(drawChart())

$ ->
  $(document).on 'change', "#only-offered-checkbox :checkbox", ->
    drawChart(this.checked)

