# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_10_09_173758) do

  create_table "admins", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "children", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name"
    t.date "birthday"
    t.integer "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id"
    t.index ["family_id"], name: "index_children_on_family_id"
  end

  create_table "diaries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "user_id"
    t.date "record_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_hilight"
    t.boolean "is_about_date"
    t.boolean "is_secret"
    t.boolean "main_in_day", default: false, null: false
    t.boolean "pinned", default: false, null: false
    t.integer "pin_priority", default: 0, null: false
    t.index ["record_at"], name: "index_diaries_on_record_at"
    t.index ["user_id"], name: "index_diaries_on_user_id"
  end

  create_table "families", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: false, null: false
  end

  create_table "habitodos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.bigint "user_id"
    t.string "uuid"
    t.integer "order_number", default: 0
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_habitodos_on_user_id"
  end

  create_table "habits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "status"
    t.string "title"
    t.integer "source_id", null: false
    t.string "source_type", null: false
    t.integer "result_type"
    t.integer "value_type"
    t.string "value_unit"
    t.boolean "reminder"
    t.text "goal"
    t.text "memo"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id", "source_type"], name: "index_habits_on_source_id_and_source_type"
  end

  create_table "histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "source_id", null: false
    t.string "source_type", null: false
    t.bigint "family_id"
    t.integer "author_id"
    t.string "title"
    t.text "content"
    t.date "target_date"
    t.boolean "about_date"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "as_profile_image"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_histories_on_author_id"
    t.index ["family_id"], name: "index_histories_on_family_id"
    t.index ["source_id", "source_type"], name: "index_histories_on_source_id_and_source_type"
    t.index ["target_date"], name: "index_histories_on_target_date"
  end

  create_table "rails_admin_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "message"
    t.string "username"
    t.integer "item"
    t.string "table"
    t.integer "month", limit: 2
    t.bigint "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item", "table", "month", "year"], name: "index_rails_admin_histories"
  end

  create_table "records", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "habit_id"
    t.date "record_at"
    t.float "value"
    t.text "memo"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id"], name: "index_records_on_habit_id"
    t.index ["record_at"], name: "index_records_on_record_at"
  end

  create_table "senses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.text "description"
    t.text "content"
    t.date "start_at"
    t.date "end_at"
    t.boolean "is_inactive"
    t.integer "sort_order", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "parent_id"
  end

  create_table "taggings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.integer "user_id"
    t.datetime "last_used_at"
    t.text "description"
    t.string "color"
    t.boolean "pinned", default: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "todos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "familyname"
    t.string "givenname"
    t.datetime "deleted_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token"
    t.string "nickname"
    t.bigint "family_id"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "children", "families"
  add_foreign_key "histories", "children", column: "source_id"
  add_foreign_key "histories", "families"
  add_foreign_key "histories", "users", column: "author_id"
  add_foreign_key "users", "families"
end
