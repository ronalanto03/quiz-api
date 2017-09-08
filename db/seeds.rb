# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



Quiz.destroy_all
include Api::V1::QuizUtilities#file located at lib/api/v1/quiz_utilities.rb

#create non-graded quiz
new_quiz = Quiz.create! ({quiz_name: "First Quiz"})
for i in (0..19)
  curr_question = new_quiz.questions.create!({text:"Question #{i}?", correct_answer_number:rand(0..5)})
  for j in (0 ..rand(5..10))
    curr_question.answers.create! ({text: "Answer#{j} of #{i}"})
  end
end

#Create a quiz and grade it, total_score = 1.0
new_quiz = Quiz.create! ({quiz_name: "Second Quiz"})
for i in (0..19)
  curr_question = new_quiz.questions.create!({text:"Question #{i}?", correct_answer_number:rand(0..5)})
  curr_question.given_answer_number = curr_question.correct_answer_number 
  curr_question.save!

  for j in (0 ..rand(5..10))
    curr_question.answers.create! ({text: "Answer#{j} of #{i}"})
  end
end

grade_info = grade_quiz(new_quiz)
new_quiz.total_score = grade_info[:total_score]
new_quiz.graded = true
new_quiz.save!


#Create a quiz and grade it, total_score = 0.5
new_quiz = Quiz.create! ({quiz_name: "Third Quiz"})
for i in (0..19)
  curr_question = new_quiz.questions.create!({text:"Question #{i}?", correct_answer_number:rand(0..5)})
  if(i%2==0)
    curr_question.given_answer_number = curr_question.correct_answer_number 
   else
    curr_question.given_answer_number = curr_question.correct_answer_number + 1
  end
  curr_question.save!

  for j in (0 ..rand(5..10))
    curr_question.answers.create! ({text: "Answer#{j} of #{i}"})
  end
end

grade_info = grade_quiz(new_quiz)
new_quiz.total_score = grade_info[:total_score]
new_quiz.graded = true
new_quiz.save!