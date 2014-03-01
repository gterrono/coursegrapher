// Generated by CoffeeScript 1.6.3
(function() {
  var DOMAIN, TOKEN, departments, departments_fetched, departments_received, dept_reviews, depts_callback, get_json, revs_callback;

  DOMAIN = 'http://api.penncoursereview.com/v1/';

  TOKEN = 'public';

  get_json = function(path, callback, options) {
    var _this = this;
    return $.get("" + DOMAIN + path + "?token=" + TOKEN, function(data) {
      data = JSON.parse(data).result;
      return callback(data, options);
    });
  };

  departments = function(callback, options) {
    var path;
    path = 'depts/';
    return get_json(path, callback, options);
  };

  dept_reviews = function(did, callback, options) {
    var path;
    path = "depts/" + did + "/reviews";
    return get_json(path, callback, options);
  };

  departments_received = 0;

  revs_callback = function(data, options) {
    var c, category, course, courses, dept, dept_averages, dept_name, dept_num, dept_totals, name, obj, temp, val, _i, _j, _len, _len1, _ref, _ref1, _ref2;
    departments_received++;
    dept_name = options.dept;
    dept = {};
    dept_totals = {};
    dept_averages = {};
    dept_averages = {};
    _ref = data.values;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      obj = _ref[_i];
      courses = (function() {
        var _j, _len1, _ref1, _results;
        _ref1 = obj.section.aliases;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          c = _ref1[_j];
          if (c.indexOf(dept_name) === 0) {
            _results.push(c.split('-')[1]);
          }
        }
        return _results;
      })();
      for (_j = 0, _len1 = courses.length; _j < _len1; _j++) {
        course = courses[_j];
        if (!dept[course]) {
          dept[course] = {
            reviews: [],
            totals: {},
            averages: {}
          };
        }
        c = dept[course];
        c.reviews.push(obj.ratings);
        _ref1 = obj.ratings;
        for (category in _ref1) {
          val = _ref1[category];
          if (!(category in c.totals)) {
            c.totals[category] = {
              sum: 0,
              num: 0
            };
          }
          c.totals[category].sum += parseFloat(val);
          c.totals[category].num++;
        }
      }
    }
    dept_num = 0;
    for (name in dept) {
      c = dept[name];
      _ref2 = c.totals;
      for (category in _ref2) {
        val = _ref2[category];
        c.averages[category] = val.sum / val.num;
        if (!(category in dept_totals)) {
          dept_totals[category] = {
            sum: 0,
            num: 0
          };
        }
        dept_totals[category].sum += c.averages[category];
        dept_totals[category].num++;
      }
      delete c.totals;
      delete c.reviews;
      dept_num++;
    }
    dept_num -= 4;
    for (category in dept_totals) {
      val = dept_totals[category];
      dept_averages[category] = val.sum / val.num;
    }
    temp = {};
    temp[dept_name] = {
      averages: dept_averages,
      num: dept_num,
      name: options.dept_full_name
    };
    depts_db.update(temp);
    temp = {};
    temp[dept_name] = dept;
    root_db.update(temp);
    if (departments_fetched === departments_received) {
      return console.log("Done: " + departments_received + " departments processed");
    }
  };

  departments_fetched = 0;

  depts_callback = function(data, options) {
    var d, _i, _len, _ref, _results;
    if (options == null) {
      options = {};
    }
    _ref = data.values;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      d = _ref[_i];
      departments_fetched++;
      options.dept = d.id;
      options.dept_full_name = d.name;
      _results.push(dept_reviews(d.id, revs_callback, _.clone(options)));
    }
    return _results;
  };

  window.update_data = function(token) {
    window.root_db = new Firebase('https://coursegrapher.firebaseio.com/');
    window.depts_db = new Firebase('https://coursegrapher.firebaseio.com/depts/');
    TOKEN = token;
    return departments(depts_callback);
  };

}).call(this);
