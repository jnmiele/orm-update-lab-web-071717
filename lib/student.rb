require_relative "../config/environment.rb"

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
  	@id = id
  	@name = name
  	@grade = grade
  end

  def self.create_table
  	sql = <<-SQL
  	  CREATE TABLE IF NOT EXISTS students (
  	  	id INTEGER PRIMARY KEY,
  	  	name TEXT,
  	  	grade INTEGER
  	  )
  	SQL
  	DB[:conn].execute(sql)
  end

  def self.drop_table
  	DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
  	# INSERTS NEW ROW INTO THE DATABASE USING THE ATTRIBUTES OF THE GIVEN OBJECT
  	if self.id
  		self.update
  	else
	  	sql = <<-SQL
	  	  INSERT INTO students (name, grade) VALUES (?, ?)
	  	SQL
	  	DB[:conn].execute(sql, self.name, self.grade)
	  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
	  end
  end

  def self.create(name, grade)
  	# Creates a student with two attributes; name and grade.
  	student = Student.new(name, grade)
  	student.save
  	student
  end

  def self.new_from_db(row)
  	# feeds [id, name, grade] => new Student with latter attributes
  	student = Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
  	# Queries the DB looking for a record by the given name then uses #new_from_db to instantiate a Student
  	sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
  	# Updates the database row mapped to the given Student instance.
  	sql = <<-SQL
  	  UPDATE students
  	  SET name = ?
  	  WHERE id = ?
  	SQL
  	DB[:conn].execute(sql, self.name, self.id)
  end
end
