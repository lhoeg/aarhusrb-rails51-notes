class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.date :due_date
      t.string :extra

      t.timestamps
    end
    add_index :posts, :title
  end
end
