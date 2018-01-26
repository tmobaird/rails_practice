class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :hm_posts do |t|
      t.string :title
      t.text :body
      t.references :user, foreign_key: { to_table: :hm_users }

      t.timestamps
    end
  end
end
