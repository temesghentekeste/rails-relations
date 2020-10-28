# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_28_153654) do

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "country"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "user_id", null: false
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_enrollments_on_game_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "events_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "event_id", null: false
    t.index ["event_id"], name: "index_events_users_on_event_id"
    t.index ["user_id"], name: "index_events_users_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_histories", force: :cascade do |t|
    t.integer "purse_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["purse_id"], name: "index_payment_histories_on_purse_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "purses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "funds"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_purses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "enrollments", "games"
  add_foreign_key "enrollments", "users"
  add_foreign_key "events_users", "events"
  add_foreign_key "events_users", "users"
  add_foreign_key "payment_histories", "purses"
  add_foreign_key "posts", "users"
  add_foreign_key "purses", "users"
end
