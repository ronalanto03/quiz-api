class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :correct_answer_number
      t.integer :given_answer_number, :default => -1
      t.string :text

      t.timestamps null: false
    end
  end
end
