# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_10_06_171710) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_graphql"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "pgjwt"
  enable_extension "pgsodium"
  enable_extension "plpgsql"
  enable_extension "supabase_vault"
  enable_extension "uuid-ossp"

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "post_id", null: false
    t.uuid "user_id", null: false
    t.jsonb "body", default: "{}", null: false
    t.string "status", null: false
    t.integer "like_count", default: 0
    t.integer "dislike_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id", "status"], name: "index_comments_on_user_id_and_status"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "group_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "group_id", null: false
    t.uuid "user_id", null: false
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "admin_id"
    t.text "description"
    t.string "profile_picture"
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["admin_id"], name: "index_groups_on_admin_id"
  end

  create_table "interactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "object_type", null: false
    t.uuid "object_id", null: false
    t.uuid "user_id", null: false
    t.boolean "is_like"
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["object_id", "object_type"], name: "index_interactions_on_object_id_and_object_type"
    t.index ["object_type", "object_id"], name: "index_interactions_on_object"
    t.index ["user_id"], name: "index_interactions_on_user_id"
  end

  create_table "posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.jsonb "body", default: "{}", null: false
    t.uuid "user_id", null: false
    t.uuid "group_id", null: false
    t.string "status", null: false
    t.integer "like_count", default: 0
    t.integer "dislike_count", default: 0
    t.integer "comment_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_posts_on_group_id"
    t.index ["status"], name: "index_posts_on_status"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "username", null: false
    t.string "email", null: false
    t.string "mobile_number"
    t.string "profile_picture"
    t.text "bio"
    t.string "password", null: false
    t.string "status", null: false
    t.string "query_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.check_constraint "(email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)", name: "users_email_change_confirm_status_check"
  end

  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "interactions", "users"
  add_foreign_key "posts", "groups"
  add_foreign_key "posts", "users"
end
