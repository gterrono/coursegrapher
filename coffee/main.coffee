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
        dept[course] = {reviews: [], totals: {}, averages: {}, name: options.dept_name}
      c = dept[course]
      c.reviews.push(obj.ratings)
      for category, val of obj.ratings
        unless category of c.totals
          c.totals[category] = {sum: 0, num: 0}
        c.totals[category].sum += parseFloat(val)
        c.totals[category].num++
  for name, c of dept
    for category, val of c.totals
      c.averages[category] = val.sum / val.num
      unless category of dept.totals
        dept.totals[category] = {sum: 0, num: 0}
      dept.totals[category].sum += c.averages[category]
      dept.totals[category].num++
    delete c.totals
    delete c.reviews
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
      options.dept_name = d.name
      database[d.id] = {totals: {}, averages: {}}
      dept_reviews(d.id, revs, _.clone(options))


google.load('visualization', '1', {'packages':['motionchart']})

google.setOnLoadCallback(drawChart)
drawChart = () ->
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
  data.addRows()
