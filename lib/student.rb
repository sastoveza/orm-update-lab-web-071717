require 'pry'
require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
  	@name = name 
  	@grade = grade
  	@id = id
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
	 	sql = <<-SQL
	 		DROP TABLE students
 		SQL
 		DB[:conn].execute(sql)
	end

	def save
		unless self.id
		sql = <<-SQL
			INSERT INTO students (name, grade)
			VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, self.name, self.grade)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() from students")[0][0]
	else
		self.update
	end
	end

	def update
		sql = <<-SQL
			UPDATE students
			SET name = ?, grade = ?
			WHERE id = ?
		SQL
		DB[:conn].execute(sql, self.name, self.grade, self.id)
	end

	def self.create(name, grade)
		student = self.new(name, grade)
		student.save
	end

	def self.new_from_db(row)
		Student.new(row[0], row[1], row[2])	
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM students
			WHERE name = ?
		SQL
		result = DB[:conn].execute(sql, name).first
		self.new_from_db(result)
	end


end
