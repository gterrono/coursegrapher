DOMAIN = 'http://api.penncoursereview.com/v1/'
TOKEN = 'public'

get_json = (path, callback, options) ->
  $.get "#{DOMAIN}#{path}?token=#{TOKEN}", (data) =>
    data = JSON.parse(data).result
    callback(data, options)

departments = (callback, options) ->
  path = 'depts/'
  get_json path, callback, options

dept_reviews = (did, callback, options) ->
  path = "depts/#{did}/reviews"
  get_json path, callback, options

database = {}

departments_received = 0
revs_callback = (data, options) ->
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
  dept.num -= 4
  for category, val of dept.totals
    dept.averages[category] = val.sum / val.num
  delete dept.totals
  db.update(_.pick(database, dept_name))
  if departments_fetched == departments_received
    console.log "Done: #{departments_received} departments processed"

departments_fetched = 0
depts_callback = (data, options={}) ->
  for d in data.values
    unless d.id of database
      departments_fetched++
      options.dept = d.id
      database[d.id] = {totals: {}, averages: {}, name: d.name}
      dept_reviews d.id, revs_callback, _.clone(options)

window.update_data = (token) ->
  window.db = new Firebase('https://coursegrapher.firebaseio.com/')
  TOKEN = token
  departments(depts_callback)
