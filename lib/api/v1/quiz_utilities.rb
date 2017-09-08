module Api::V1::QuizUtilities

  def grade_quiz(quiz)
  	total_score = 0.0
  	summary_array = Array.new
    for i in (0..19)
      question = quiz.questions[i]
      if(question.given_answer_number!=-1)
      	if question.given_answer_number == question.correct_answer_number
      	  total_score += 1.0
      	else
      	  summary_array.push (question.text) 
      	end
      else
      	return {:errors => "Quiz can not be graded because there are questions not answered"}
      end
    end

    total_score = total_score/20
    return {:total_score => total_score, :summary=> summary_array}
  end


	      #Generate the json related to the quiz
  #returns a json object that represents the quiz
  def quiz_to_json(quiz)
  	  if(quiz.graded == true)
  	  	summary = Array.new
  	  	for i in (0..19)
  	  	  question = quiz.questions[i]
  	  	  if(question.given_answer_number != question.correct_answer_number)
  	  	  	summary.push(question.text)
  	  	  end
  	  	end
        quiz_info = {"id" => quiz.id, "quiz_name" => quiz.quiz_name, "graded"=>quiz.graded, "total_score"=>quiz.total_score, "summary"=>summary}
      else
        quiz_info = {"id" => quiz.id, "quiz_name" => quiz.quiz_name, "graded"=>quiz.graded}
      end
      json = { 
               "quiz_info" => quiz_info,#{"id"=>quiz.id, "quiz_name"=>quiz.quiz_name},
               "questions" => quiz.questions.map do |question|
                 question_info = {"question_info" => JSON.parse(question.to_json(:only => [:correct_answer_number, :text]))}
                 question_info.merge({
                   "answers" => question.answers.map do |answer|
                      JSON.parse(answer.to_json(:only => [:text]))
                    end
                   }
                 )
                end
              }
  end


  #This function validates and convert a json into a quiz object for the creation in the DB
  #returns an array[passed, info]. 
  #passed can be true(in case the json represents a valid quiz for api v1) or false otherwise
  def json_to_quiz_creation_validator(json)
    if(json.count  == 2 and
       json['quiz_info'] and
       json['quiz_info'].count == 1 and
       json['quiz_info']['quiz_name'])
      
      quiz = Quiz.new (json['quiz_info'])
      retval = {:data => quiz}
    else
    	return {:errors => "\"quiz_info\" must be present and well formed"}
    end

    question_hash = json_to_questions(json['questions'])
    if(!question_hash[:data])
    	return question_hash
    else
    	quiz.questions<<question_hash[:data]
    end

    return retval
  end



  #This function validates and convert a json into a quiz object for the creation in the DB
  #returns an array[passed, info]. 
  #passed can be true(in case the json represents a valid quiz for api v1) or false otherwise
  def json_to_quiz_update_validator(json)
    if(json.count  == 2 and
       json['quiz_info'] and
       json['quiz_info'].count == 2 and
       json['quiz_info']['quiz_name'] and
       json['quiz_info']['id'])
      
      begin
        quiz = Quiz.find(json['quiz_info']['id'])
        retval = {:data => quiz}
  	  rescue ActiveRecord::RecordNotFound => e
        return {:not_found => 'Quiz not found'}
      end
    else
      return {:errors => 'quiz_info not present or bad-formatted'}      
    end

    # p quiz


    question_hash = json_to_questions(json['questions'])
    if(!question_hash[:data])
    	return question_hash
    else
    	quiz.questions<<question_hash[:data]
    end

    return retval
  end


  def compare_json_and_object_quiz(json, quiz)
  	quiz_info = json['quiz_info']
  	passed = quiz_info != nil and quiz_info['quiz_name'] != nil and (quiz_info['quiz_name'] == quiz.quiz_name)

    questions_json = json['questions']
  	passed = passed and questions_json.is_a?(Array) and questions_json.count == 20 and quiz.questions.count == 20
  	return false if passed == false

  	for i in (0..19)
  	  question = quiz.questions[i]
  	  question_json = questions_json[i]
  	  # p question_json
  	  passed = passed and question_json['question_info'] != nil and
  	           question_json['question_info']['correct_answer_number'] == question.correct_answer_number and
  	           question_json['question_info']['text'] == question.text and
  	           question_json['answers'] != nil and
  	           question_json['answers'].is_a?(Array) and
  	           question_json['answers'].count == question.answers.count
  	  return false if passed == false

  	  for j in (0..question.answers.count-1)
  	    answer = question.answers[j]
  	    answer_json = question_json['answers'][j]

  	    passed = passed and answer_json['text'] == answer.text

  	  end

  	end

    return passed
  end



  private


  #This function validates and convert a json into a question object for the creation in the DB
  def json_to_question(json)

  	if(json.count == 2 and json['question_info'] and
  	   json['question_info'].count == 2 and
  	   json['question_info']['text'] and
  	   json['question_info']['correct_answer_number'])
      
      question = Question.new (json['question_info'])
    else
      return {:errors => 'question_info is not present or bad-formatted'}
    end
    answers_json = json['answers']
    if(answers_json and
       answers_json.is_a? (Array) and
       answers_json.count > 2)
       for i in (0..answers_json.count-1)
       	 if(answers_json[i].count == 1 and
       	 	answers_json[i]['text'])
           question.answers.new (answers_json[i])
         else
           return {:errors => 'answer is bad-formatted'}
         end
       end

    else
      return {:errors => 'answers is not present or bad-formatted'}

    end

  	return {:data => question}
  end


  def json_to_questions(json)
    questions_json = json
    questions = Array.new
    if(questions_json and questions_json.is_a?(Array) and questions_json.count == 20)
      for i in (0..19)
      	question_hash = json_to_question(questions_json[i])
      	if(!question_hash[:data])
      	  return question_hash
      	end
        questions.push(question_hash[:data])
      end

      return {:data => questions}
    else
      return {:errors => "\"questions\" must be present"}      	
    end
  end


end