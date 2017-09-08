class Question < ActiveRecord::Base
   has_many :answers, dependent: :destroy
   belongs_to :quiz
   validates :text, presence: true
   validates :correct_answer_number, presence: true
end
