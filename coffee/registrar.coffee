api = require 'penn-sdk'
Firebase = require 'firebase'

registrar = new api.Registrar process.env.API_UN, process.env.API_PW
root_db = new Firebase('https://coursegrapher.firebaseio.com/')

root_db.once "value", (db) ->
  for dept_name, dept_db of db.val()
    update_dept dept_name, dept_db

update_dept = (dept_name, dept_db) ->
  if dept_name == "depts"
    return
  # assume all courses in pcr are not offered this semester
  for k,c of dept_db
    c.offered = false
  # update the ones that are offerred
  registrar.search {course_id: dept_name}, (courses) ->
    for c in courses
      # console.log "[#{c.course_department}-#{c.course_number}-#{c.section_number}(#{c.activity})] #{c.course_title} (#{c.course_status_normalized})"
      if dept_db[c.course_number] and c.course_status == "O"
        dept_db[c.course_number].offered = true
    temp = {}
    temp[dept_name] = dept_db
    root_db.update temp
    console.log "successfully updated department: #{dept_name}"
