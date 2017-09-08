class Quiz < ActiveRecord::Base
  has_many :questions, dependent: :destroy

  validates :quiz_name, presence: true
end
