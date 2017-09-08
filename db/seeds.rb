# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
      Quiz.destroy_all
      new_quiz = Quiz.create! ({quiz_name: "First Quiz"})

      for i in (0..19)
        curr_question = new_quiz.questions.create!({text:"Question #{i}?", correct_answer_number:rand(0..5)})
        for j in (0 ..rand(5..10))
          curr_question.answers.create! ({text: "Answer#{j} of #{i}"})
        end
      end