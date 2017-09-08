class Api::V1::QuizzesController < ApplicationController
  respond_to :json
  include Api::V1::QuizUtilities#file located at lib/api/v1/quiz_utilities.rb
  skip_before_action :verify_authenticity_token


  #############################################################################
  def show
  	begin
      quiz = Quiz.find(user_params[:id])
  	rescue ActiveRecord::RecordNotFound => e
      quiz = nil  		
    end

    if quiz
      render status: 200,
        json: JSON.pretty_generate(quiz_to_json(quiz))
    else
      render status: 404,  json: { error: 'Quiz not found' }
    end

  end

  #############################################################################
  def grade
    begin
      quiz = Quiz.find(user_params[:id])
    rescue ActiveRecord::RecordNotFound => e
      quiz = nil      
    end
    if quiz
      grade_info = grade_quiz(quiz)
      if(grade_info[:total_score])
        quiz.total_score = grade_info[:total_score]
        quiz.graded = true

        if(quiz.save)
          render status: 200,
               json: {total_score: grade_info[:total_score],
                      summary: grade_info[:summary]}
        else
          render status: 405, 
               json: { error: quiz.errors.full_messages.to_sentence }

        end

      else
        render status: 405, 
               json: { error: grade_info[:errors] }
      end
    else
      render status: 404,  json: { error: 'Quiz not found' }
    end
  end

  #############################################################################
  def create
    information = request.raw_post
    data_parsed = JSON.parse(information)

    quiz_hash = json_to_quiz_creation_validator(data_parsed)
    if(quiz_hash[:data] and quiz_hash[:data].save)
      render status: 200,
           json: {id: quiz_hash[:data].id}
    else
      if(quiz_hash[:data])
        errors = quiz_hash[:data].errors.full_messages.to_sentence
      else
        errors = quiz_hash[:errors]
      end
      render status: 405,
           json: {error: errors}
    end
  end

  #############################################################################
  def edit
    information = request.raw_post
    data_parsed = JSON.parse(information)
    # p data_parsed

    quiz_hash = json_to_quiz_update_validator(data_parsed)
    if(quiz_hash[:not_found])
      render status: 404,
           json: {erros: "Quiz not founds"}
           return
     end


    if(quiz_hash[:data] and quiz_hash[:data].save)
      render status: 200,
           json: {id: quiz_hash[:data].id}
    else
      if(quiz_hash[:data])
        errors = quiz_hash[:data].errors.full_messages.to_sentence
      else
        errors = quiz_hash[:errors]
      end
      # p errors
      render status: 405,
           json: {error: errors}
    end    
  end

  #############################################################################
  def answer
    quiz_id = user_params[:quiz_id]
    question_number = user_params[:question_number]
    answer_number = user_params[:answer_number]

    if(quiz_id and question_number and answer_number)
      begin
        quiz = Quiz.find(quiz_id)
      rescue ActiveRecord::RecordNotFound => e
        render status: 404,  json: { error: 'Quiz not found' }
        return
      end
    quiz_id = quiz_id.to_i
    question_number = question_number.to_i
    answer_number = answer_number.to_i

  
      if(question_number >= 1 and question_number <= quiz.questions.count)
        question = quiz.questions[question_number - 1]
        if(answer_number >= 1 and answer_number <= question.answers.count)
          question.given_answer_number = answer_number
          if question.save
            render status: 200,  json: { message: 'Question was updated' }
          else
            render status: 405,  json: { error: question.errors.full_messages.to_sentence }            
          end

        else
          render status: 405,  json: { error: 'answer_number is invalid' }
        end
      else
        render status: 405,  json: { error: 'question_number is invalid' }
      end

    else
      render status: 405,  json: { error: 'Missing one parameter' }

    end

  end


 private
  #############################################################################
  def user_params
    params.permit(:id,:quiz_id, :question_number,:answer_number)
  end

end
