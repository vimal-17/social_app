class CreateSocialNetworkSchema < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.string :name, null: false
      t.string :username, null: false
      t.string :email, null: false
      t.string :mobile_number
      t.string :profile_picture
      t.text :bio
      t.string :password, null: false  # Store encrypted passwords
      t.string :status, null: false
      t.string :query_name
      t.timestamps
    end

    create_table :posts, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.string :title, null: false
      t.jsonb :body, null: false, default: '{}' # Use jsonb for post content
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :group, type: :uuid, null: false, foreign_key: true
      t.string :status, null: false
      t.integer :like_count, default: 0
      t.integer :dislike_count, default: 0
      t.integer :comment_count, default: 0
      t.timestamps
    end

    create_table :groups, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.string :name, null: false
      t.uuid :admin_id, type: :uuid, foreign_key: { to_table: :users }, index: true
      t.text :description
      t.string :profile_picture
      t.string :status, null: false
      t.timestamps
    end

    # mapping table for groups and users
    create_table :group_users, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.references :group, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :status, null: false
      t.timestamps
    end

    create_table :comments, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.references :post, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.jsonb :body, null: false, default: '{}'
      t.string :status, null: false
      t.integer :like_count, default: 0
      t.integer :dislike_count, default: 0
      t.timestamps
    end

    create_table :interactions, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.references :object, type: :uuid, polymorphic: true, null: false # Polymorphic relation to posts or comments
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.boolean :is_like
      t.string :status, null: false
      t.timestamps
    end

    # Add a unique index to the combination of email and mobile_number
    # add_index :users, [:email, :mobile_number], unique: true
    # add_index :users, :username, unique: true

    add_index :posts, :status
    add_index :group_users, [:group_id, :user_id], unique: true
    add_index :comments, [:user_id, :status]
    add_index :interactions, [:object_id, :object_type] # Polymorphic index for interactions
  end
end
