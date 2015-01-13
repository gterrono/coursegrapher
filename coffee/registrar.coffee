api = require 'penn-sdk'
Firebase = require 'firebase'

registrar = new api.Registrar process.env.API_UN, process.env.API_PW
root_db = new Firebase('https://coursegrapher.firebaseio.com/')

root_db.once "value", (data) ->
  db = data.val()
  depts_db = db["depts"]
  for dept_name, dept_db of db
    unless dept_name == "depts"
      update_dept dept_name, dept_db, depts_db

update_dept = (dept_name, dept_db, depts_db) ->
  # assume all courses in pcr are not offered this semester
  for k,c of dept_db
    c.offered = false
  # update the ones that are offerred
  registrar.search {course_id: dept_name}, (courses) ->
    discovered = {}
    course_count = 0
    for c in courses
      # console.log "[#{c.course_department}-#{c.course_number}-#{c.section_number}(#{c.activity})] #{c.course_title} (#{c.course_status_normalized})"
      if dept_db[c.course_number] and c.course_status == "O"
        dept_db[c.course_number].offered = true
      unless c.course_number of discovered
        discovered[c.course_number] = true
        course_count++
    temp = {}
    temp[dept_name] = dept_db
    root_db.update temp
    console.log "successfully updated department: #{dept_name}"
    temp = {}
    temp[dept_name] = depts_db[dept_name]
    temp[dept_name].course_count = course_count
    root_db.child("depts").update temp
