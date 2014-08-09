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

ActiveRecord::Schema.define(version: 20140809143818) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.boolean  "proposed",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",   default: false, null: false
  end

  add_index "assignments", ["project_id", "user_id"], name: "index_assignments_on_project_id_and_user_id", unique: true, using: :btree

  create_table "clients", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: true do |t|
    t.integer "user_id"
    t.integer "company_id"
    t.boolean "disabled",                                      default: false, null: false
    t.boolean "archived",                                      default: false, null: false
    t.decimal "salary",               precision: 12, scale: 2
    t.decimal "rate",                 precision: 10, scale: 2
    t.decimal "full_time_equivalent", precision: 12, scale: 2
    t.string  "payment_frequency"
    t.integer "weekly_allocation"
    t.string  "employment_status",                             default: "fte", null: false
    t.integer "permissions",                                   default: 0,     null: false
  end

  add_index "memberships", ["company_id", "user_id"], name: "index_memberships_on_company_id_and_user_id", unique: true, using: :btree

  create_table "projects", force: true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.boolean  "active",                                     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.boolean  "proposed",                                   default: false,   null: false
    t.decimal  "cost",              precision: 12, scale: 2, default: 0.0,     null: false
    t.string   "payment_frequency",                          default: "total", null: false
  end

  create_table "user_preferences", force: true do |t|
    t.boolean  "email_reminder"
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "display_dates",  default: false, null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_company_id"
    t.string   "registration_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "work_weeks", force: true do |t|
    t.integer  "estimated_hours"
    t.integer  "actual_hours"
    t.integer  "cweek",             limit: 2
    t.integer  "year",              limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignment_id"
    t.decimal  "beginning_of_week",           precision: 15, scale: 0
  end

  add_index "work_weeks", ["assignment_id", "beginning_of_week"], name: "index_work_weeks_on_assignment_id_and_beginning_of_week", unique: true, using: :btree

end
