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
  for name, c of dept
    for category, val of c.totals
      c.averages[category] = val.sum / val.num

window.ch = (data, options) ->
  dept = options.dept
  options.courses =
    (c.substr(c.length-3) for c in data.aliases when c.indexOf(dept) == 0)
  reviews(data.id, revs, options)

window.dept = (data, options) ->
  options.dept = data.id
  unless data.id of database
    database[data.id] = {}
    dept_reviews(data.id, revs, options)

window.departments_fetched = 0
window.depts = (data, options={}) ->
  for d in data.values
    unless d.id of database
      departments_fetched++
      options.dept = d.id
      database[d.id] = {}
      dept_reviews(d.id, revs, options)
