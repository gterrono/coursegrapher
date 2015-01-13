CourseGrapher
=============
Thie is a site that graphs [PennCourseReview] (http://penncoursereview.com) data in bubble charts using the Google Charts api.  This is a more maintainable rewrite of an app that won second place at [PennApps Hackathon] (http://pennapps.com) in September 2011.


Notes
----
The graph can't be shown by just viewing the file in the browser. You can test it locally by running `python -m SimpleHTTPServer` in the directory.

To compile the coffeescript, use `coffee -o js -c coffee`.

To deploy, push to gh-pages.

To update the review data, set write to true on Firebase and run `update_data(<token>)` in the console on [the site](http://coursegrapher.com). It should take about 15 minutes, and it will log when it's done. Then set write back to false.
