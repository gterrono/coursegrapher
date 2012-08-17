require 'json'
require 'net/http'
require 'data_mapper'
require_relative 'models'

def get_uri(path)
  uri_start = 'http://api.penncoursereview.com/v1'
  token = '?token=asdlkja4lks94nklvm34lkdf09lkns'
  URI("#{uri_start}#{path}#{token}")
end

def get_json(path)
  uri = get_uri(path)
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end

def get_data()
  data = get_json('/depts')
  depts = data['result']['values']
  depts.each do |dept|
    process_dept(dept)
  end
end

def process_dept(dept)
  data = get_json(dept['path'])
  courses = data['result']['coursehistories']
  department = Department.new(:name => dept['id'])
  puts department.name, department.save
  courses.each do |course|
    department.add process_course(course)
    department = Department.get(department.id)
  end
end

$key_dict = {
  :access_inst => "rInstructorAccess",
  :amount_learned => "rAmountLearned",
  :amount_work => "rWorkRequired",
  :course_quality => "rCourseQuality",
  :difficulty => "rDifficulty",
  :inst_quality => "rInstructorQuality",
  :inst_communication => "rCommAbility",
  :rec_majors => "rRecommendMajor",
  :rec_non_majors => "rRecommendNonMajor",
  :stim_int => "rStimulateInterest",
  :val_of_readings => "rReadingsValue"
}

def process_course(course)
  data = get_json("#{course['path']}/reviews")
  reviews = data['result']['values']
  compilation = {:num_reviews => 0}
  $key_dict.each_key {|k| compilation[k] = 0.0}
  num = 0
  reviews.each {|review| num = process_review(review, compilation, num)}
  return nil if num == 0
  compilation.each_key {|k| compilation[k]/=num}
  compilation[:name] = course['aliases'][0]
  Course.create(compilation)
end

def process_review(review, compilation, num)
  return num if review['num_reviewers'].nil?
  ratings = review['ratings']
  $key_dict.each_value {|v| return num if ratings[v].nil?}
  compilation[:num_reviews] += review['num_reviewers']
  $key_dict.each {|k, v| compilation[k] += ratings[v].to_f}
  num + 1
end
