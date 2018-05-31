class AddAcceptedToAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :answers, :accepted, :boolean, default: false
  end
end
