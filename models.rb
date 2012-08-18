DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/cg.db")

DataMapper::Property::Float.default(0.0)

class Course
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :access_inst, Float
  property :amount_learned, Float
  property :amount_work, Float
  property :course_quality, Float
  property :difficulty, Float
  property :inst_quality, Float
  property :inst_communication, Float
  property :num_reviews, Integer, :default => 0
  property :rec_majors, Float
  property :rec_non_majors, Float
  property :stim_int, Float
  property :val_of_readings, Float

  belongs_to :department
end

class Department
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :access_inst, Float
  property :amount_learned, Float
  property :amount_work, Float
  property :course_quality, Float
  property :difficulty, Float
  property :inst_quality, Float
  property :inst_communication, Float
  property :num_reviews, Integer, :default => 0
  property :rec_majors, Float
  property :rec_non_majors, Float
  property :stim_int, Float
  property :val_of_readings, Float

  has n, :courses

  def each_rating
    self.attributes.each do |k, v|
      if v.is_a? Float
        yield k
      end
    end
  end

  def add(course)
    return if course.nil?
    num_courses = self.courses.length
    each_rating do |key|
      self[key] = (self[key]*num_courses + course[key])/(num_courses + 1)
    end
    self[:num_reviews] += course[:num_reviews]
    self.courses.push course
    course.save
  end
end

DataMapper.auto_migrate!
