class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.timestamps
    end

    add_reference :questions, :user, foreign_key: true, null: true
    add_reference :answers,   :user, foreign_key: true, null: true
  end
end
