# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140213225400) do

  create_table "approvers", force: true do |t|
    t.integer  "user_id"
    t.integer  "change_id"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "approvers", ["change_id"], name: "index_approvers_on_change_id", using: :btree
  add_index "approvers", ["user_id"], name: "index_approvers_on_user_id", using: :btree

  create_table "attachments", force: true do |t|
    t.integer  "change_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
  end

  create_table "change_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "changes", force: true do |t|
    t.string   "title"
    t.text     "summary"
    t.text     "impact"
    t.text     "rollback"
    t.datetime "expected_change_date"
    t.integer  "priority_id"
    t.integer  "status_id"
    t.integer  "system_id"
    t.integer  "change_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "impact_id"
    t.integer  "created_by"
    t.datetime "change_date"
  end

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",   default: 0
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",          default: 0, null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.integer  "change_id"
    t.string   "event_type"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["change_id"], name: "index_events_on_change_id", using: :btree

  create_table "impacts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "priorities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree

  create_table "statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "systems", force: true do |t|
    t.string   "group"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
