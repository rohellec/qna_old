class CreateVotes < ActiveRecord::Migration[5.1]
  def up
    create_table :votes do |t|
      t.integer :value
      t.references :votable, polymorphic: true
      t.references :user, foreign_key: true
    end

    execute <<-SQL
      ALTER TABLE votes ADD CONSTRAINT check_vote_value CHECK (value IN (-1, 1) )
    SQL
  end

  def down
    drop_table :votes
  end
end
