window.db = new Firebase('https://coursegrapher.firebaseio.com/')

window.database = {}

window.departments_received = 0
window.revs = (data, options) ->
  departments_received++
  dept_name = options.dept
  dept = database[dept_name]
  for obj in data.values
    courses =
      (c.split('-')[1] for c in obj.section.aliases when c.indexOf(dept_name) == 0)
    for course in courses
      unless dept[course]
        dept[course] = {reviews: [], totals: {}, averages: {}}
      c = dept[course]
      c.reviews.push(obj.ratings)
      for category, val of obj.ratings
        unless category of c.totals
          c.totals[category] = {sum: 0, num: 0}
        c.totals[category].sum += parseFloat(val)
        c.totals[category].num++

  dept.num = 0
  for name, c of dept
    for category, val of c.totals
      c.averages[category] = val.sum / val.num
      unless category of dept.totals
        dept.totals[category] = {sum: 0, num: 0}
      dept.totals[category].sum += c.averages[category]
      dept.totals[category].num++
    delete c.totals
    delete c.reviews
    dept.num++
  for category, val of dept.totals
    dept.averages[category] = val.sum / val.num
  delete dept.totals
  db.update(_.pick(database, dept_name))
  if departments_fetched == departments_received
    console.log "Done: #{departments_received} departments processed"

window.departments_fetched = 0
window.depts = (data, options={}) ->
  for d in data.values
    unless d.id of database
      departments_fetched++
      options.dept = d.id
      database[d.id] = {totals: {}, averages: {}, name: d.name}
      dept_reviews(d.id, revs, _.clone(options))


google.load('visualization', '1', {'packages':['motionchart']})

window.drawChart = () ->
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
  db.on 'value', (snapshot) ->
    row = (id, dept) ->
      return null unless dept.num?
      get = (field) ->
        dept.averages[field] or 0
      [
        "#{dept.name} (#{id})"
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
        dept.num
      ]
    a = (row(k, v) for k, v of snapshot.val())
    data.addRows(_.filter(a, _.isArray))
    chart = new google.visualization.MotionChart(document.getElementById('chart_div'))
    options = {}
    options['state'] =
      '{"showTrails":true,"playDuration":15000,"iconType":"BUBBLE","xLambda":1,"yZoomedDataMin":null,"xZoomedDataMin":null,"yLambda":1,"yZoomedIn":false,"nonSelectedAlpha":0.4,"orderedByY":false,"uniColorForNonSelected":false,"xZoomedIn":false,"time":"notime","yAxisOption":"3","xZoomedDataMax":null,"dimensions":{"iconDimensions":["dim0"]},"sizeOption":"12","duration":{"multiplier":1,"timeUnit":"D"},"yZoomedDataMax":null,"xAxisOption":"2","iconKeySettings":[],"orderedByX":false,"colorOption":"4"};'

    options['showYScalePicker'] = false
    options['showXScalePicker'] = false
    options['width'] = 950
    options['height'] = 450
    chart.draw(data, options)

    google.visualization.events.addListener(chart, 'statechange', (e) ->
      return unless chart.getState() == null
      state = JSON.parse(chart.getState())
      longtitle = state.iconKeySettings[0].key.dim0
      pat = /[(]([\w]{1,5})[)]$/
      m = longtitle.match(pat)
      dept = m[1]
      window.location = '/course/'+dept)
    console.log 'drawn'

google.setOnLoadCallback(drawChart)
