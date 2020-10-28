class CreatePurses < ActiveRecord::Migration[6.0]
  def change
    create_table :purses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :funds

      t.timestamps
    end
  end
end
