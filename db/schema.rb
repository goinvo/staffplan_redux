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

ActiveRecord::Schema[7.1].define(version: 2024_02_27_134950) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.string "status", default: "proposed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "starts_on"
    t.date "ends_on"
    t.index ["project_id"], name: "index_assignments_on_project_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_clients_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_id"
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "user_id", null: false
    t.string "status", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "user_id"], name: "index_memberships_on_company_id_and_user_id", unique: true
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.string "authenticatable_type"
    t.bigint "authenticatable_id"
    t.datetime "timeout_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "claimed_at", precision: nil
    t.string "token_digest", null: false
    t.string "identifier", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
    t.index ["identifier"], name: "index_passwordless_sessions_on_identifier", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name", null: false
    t.string "status", default: "proposed", null: false
    t.decimal "cost", precision: 12, scale: 2, default: "0.0", null: false
    t.string "payment_frequency", default: "monthly", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "starts_on"
    t.date "ends_on"
    t.index ["client_id", "name"], name: "index_projects_on_client_id_and_name", unique: true
    t.index ["client_id"], name: "index_projects_on_client_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "expires_at", null: false
    t.datetime "registered_at"
    t.string "token_digest", null: false
    t.uuid "identifier", default: -> { "gen_random_uuid()" }, null: false
    t.integer "user_id"
    t.string "ip_address", limit: 15, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name"
    t.index ["identifier"], name: "index_registrations_on_identifier", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "stripe_id"
    t.string "stripe_price_id"
    t.string "customer_name"
    t.string "customer_email"
    t.integer "plan_amount"
    t.integer "quantity"
    t.date "current_period_start"
    t.date "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.datetime "trial_end"
    t.string "item_id"
    t.string "default_payment_method"
    t.datetime "canceled_at", precision: nil
    t.string "payment_method_type"
    t.jsonb "payment_metadata", default: {}
    t.index ["company_id"], name: "index_subscriptions_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_company_id", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "work_weeks", force: :cascade do |t|
    t.bigint "assignment_id", null: false
    t.integer "cweek", null: false
    t.integer "year", null: false
    t.integer "estimated_hours", default: 0, null: false
    t.integer "actual_hours", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id", "cweek", "year"], name: "index_work_weeks_on_assignment_id_and_cweek_and_year", unique: true
    t.index ["assignment_id"], name: "index_work_weeks_on_assignment_id"
  end

  add_foreign_key "subscriptions", "companies"
end
