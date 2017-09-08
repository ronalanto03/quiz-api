require "rails_helper"

describe 'Quizzes API V1', type: :request do
  include Api::V1::QuizUtilities

  describe "Get a quiz by id" do
    it "on success, returns a quiz" do

      Quiz.destroy_all
      new_quiz = Quiz.create! ({quiz_name: "First Quiz"})

      for i in (0..20)
        curr_question = new_quiz.questions.create!({text:"#{i}What is ...?", correct_answer_number:rand(0..5)})
        for j in (0 ..rand(5..10))
          curr_question.answers.create! ({text: "Answer#{j} of #{i}"})
        end
      end

      get "/api/v1/quizzes/"+new_quiz.id.to_s
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}"
      comparison = compare_json_and_object_quiz(JSON.parse(response.body), new_quiz)
      expect(true).to eq(comparison)
    end
  end




  describe "Create a quiz" do
    it "on success a new quiz is created" do

      Quiz.destroy_all
      json_content = File.read(File.dirname(__FILE__) + '/quiz1.json')

      post "/api/v1/quizzes", json_content
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}"
      id = JSON.parse(response.body)['id']

      begin
        quiz = Quiz.find(id)    
      rescue ActiveRecord::RecordNotFound => e
        quiz = nil
      end

      expect(quiz).not_to be(nil)
      expect(compare_json_and_object_quiz(JSON.parse(json_content), quiz)).to eq(true)
    end
  end

  describe "Update a quiz and answer a question" do
    it "on success, a quiz is created, updated and a question is answered" do

      Quiz.destroy_all


       # Create new quiz
      json_content = File.read(File.dirname(__FILE__) + '/quiz1.json')
      post "/api/v1/quizzes", json_content
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}"
      id = JSON.parse(response.body)['id']

      begin
        quiz = Quiz.find(id)    
      rescue ActiveRecord::RecordNotFound => e
        quiz = nil
      end

      expect(quiz).not_to be(nil)

      expect(compare_json_and_object_quiz(JSON.parse(json_content), quiz)).to eq(true)

      #update the quiz
      json_content = File.read(File.dirname(__FILE__) + '/quiz2.json')

      put "/api/v1/quizzes", json_content
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}"
      id = JSON.parse(response.body)['id']



      #answer a question
      begin
        quiz = Quiz.find(id)
      rescue ActiveRecord::RecordNotFound => e
        quiz = nil
      end

      expect(quiz).not_to be(nil)

      expect(compare_json_and_object_quiz(JSON.parse(json_content), quiz)).to eq(true)
      question = quiz.questions[0]
      expect(question.given_answer_number).to eq(-1)

      put "/api/v1/answer", {quiz_id: 1, question_number: 1, answer_number: 3}

      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}"
      question.reload
      expect(question.given_answer_number).to eq(3)

    end
  end

  describe "Grade quizzes" do
    it "on success, a quiz will be graded 2 times" do
      Quiz.destroy_all


       # Create new quiz
      json_content = File.read(File.dirname(__FILE__) + '/quiz1.json')
      post "/api/v1/quizzes", json_content
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}"
      id = JSON.parse(response.body)['id']

      begin
        quiz = Quiz.find(id)    
      rescue ActiveRecord::RecordNotFound => e
        quiz = nil
      end

      expect(quiz).not_to be(nil)
      expect(compare_json_and_object_quiz(JSON.parse(json_content), quiz)).to eq(true)

      #grade the quiz
      put "/api/v1/grade/"+id.to_s
      expect(response.status).to eq(405)

      #changes all answers to get the highest grade
      for i in (0..19)
        question = quiz.questions[i]
        question.given_answer_number = question.correct_answer_number
        question.save
      end

      put "/api/v1/grade/"+id.to_s
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}" 
      total_score = JSON.parse(response.body)['total_score']
      expect(total_score).to eq(1.0), "#{JSON.parse(response.body)['error']}" 

      #changes some answers to get the lower grade
      for i in (0..9)
        question = quiz.questions[i]
        question.given_answer_number = question.given_answer_number + 1
        question.save
      end

      put "/api/v1/grade/"+id.to_s
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}" 
      total_score = JSON.parse(response.body)['total_score']
      summary = JSON.parse(response.body)['summary']
      expect(total_score).to eq(0.5), "#{JSON.parse(response.body)['error']}" 
      expect(summary.count).to eq(10), "#{JSON.parse(response.body)['error']}" 

      # //get a graded quiz
      get "/api/v1/quizzes/"+id.to_s
      expect(response.status).to eq(200), "#{JSON.parse(response.body)['error']}"
      total_score = JSON.parse(response.body)['quiz_info']['total_score']
      summary = JSON.parse(response.body)['quiz_info']['summary']
      graded = JSON.parse(response.body)['quiz_info']['graded']
      expect(total_score).to eq(0.5), "#{JSON.parse(response.body)['error']}" 
      expect(summary.count).to eq(10), "#{JSON.parse(response.body)['error']}" 
      expect(graded).to eq(true), "#{JSON.parse(response.body)['graded']}" 

    end

  end

end
