// Generated by CoffeeScript 1.8.0
(function() {
  var Firebase, api, registrar, root_db, update_dept;

  api = require('penn-sdk');

  Firebase = require('firebase');

  registrar = new api.Registrar(process.env.API_UN, process.env.API_PW);

  root_db = new Firebase('https://coursegrapher.firebaseio.com/');

  root_db.once("value", function(db) {
    var dept_db, dept_name, _ref, _results;
    _ref = db.val();
    _results = [];
    for (dept_name in _ref) {
      dept_db = _ref[dept_name];
      _results.push(update_dept(dept_name, dept_db));
    }
    return _results;
  });

  update_dept = function(dept_name, dept_db) {
    var c, k;
    if (dept_name === "depts") {
      return;
    }
    for (k in dept_db) {
      c = dept_db[k];
      c.offered = false;
    }
    return registrar.search({
      course_id: dept_name
    }, function(courses) {
      var temp, _i, _len;
      for (_i = 0, _len = courses.length; _i < _len; _i++) {
        c = courses[_i];
        if (dept_db[c.course_number] && c.course_status === "O") {
          dept_db[c.course_number].offered = true;
        }
      }
      temp = {};
      temp[dept_name] = dept_db;
      root_db.update(temp);
      return console.log("successfully updated department: " + dept_name);
    });
  };

}).call(this);