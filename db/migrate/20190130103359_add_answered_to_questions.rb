class AddAnsweredToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :answered, :boolean, default: false
  end
end
