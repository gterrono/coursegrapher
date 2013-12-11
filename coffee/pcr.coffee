DOMAIN = 'http://api.penncoursereview.com/v1/'

get_json = (path, callback, options) ->
  $.get("#{DOMAIN}#{path}?token=#{TOKEN}", (data) =>
    data = JSON.parse(data).result
    callback(data, options))

window.review = (cid, sid, iid, callback, options) ->
  path = "courses/#{cid}/sections/#{sid}/reviews/#{iid}"
  get_json(path, callback, options)

window.instructor = (iid, callback, options) ->
  path = "instructors/#{iid}"
  get_json(path, callback, options)

window.section = (cid, sid, callback, options) ->
  path = "courses/#{cid}/sections/#{sid}"
  get_json(path, callback, options)

window.course = (cid, callback, options) ->
  path = "courses/#{cid}"
  get_json(path, callback, options)

window.course_history = (chid, callback, options) ->
  path = "coursehistories/#{chid}"
  get_json(path, callback, options)

window.department = (did, callback, options) ->
  path = "depts/#{did}"
  get_json(path, callback, options)

window.departments = (callback, options) ->
  path = 'depts/'
  get_json(path, callback, options)

window.ch_reviews = (chid, callback, options) ->
  path = "coursehistories/#{chid}/reviews"
  get_json(path, callback, options)

window.dept_reviews = (did, callback, options) ->
  path = "depts/#{did}/reviews"
  get_json(path, callback, options)
