class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.string :file
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
