class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.timestamps
    end

    add_reference :questions, :user, foreign_key: true
    add_reference :answers,   :user, foreign_key: true
  end
end
