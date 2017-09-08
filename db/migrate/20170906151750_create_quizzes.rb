class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.string :quiz_name
      t.boolean :graded, :default => false
      t.float :total_score, :default => 0.0

      t.timestamps null: false
    end
  end
end
