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

ActiveRecord::Schema[8.1].define(version: 2026_04_30_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "expense_records", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_expense_records_on_trip_id"
  end

  create_table "fuel_records", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_fuel_records_on_trip_id"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "destination"
    t.string "origin"
    t.datetime "updated_at", null: false
  end

  create_table "shift_assignments", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "driver_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["driver_id"], name: "index_shift_assignments_on_driver_id"
    t.index ["vehicle_id"], name: "index_shift_assignments_on_vehicle_id"
  end

  create_table "trips", force: :cascade do |t|
    t.decimal "cash_collected"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.bigint "route_id"
    t.datetime "start_time"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id"
    t.index ["company_id"], name: "index_trips_on_company_id"
    t.index ["route_id"], name: "index_trips_on_route_id"
    t.index ["vehicle_id"], name: "index_trips_on_vehicle_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "role"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.integer "capacity"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "driver_id"
    t.string "plate_number"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_vehicles_on_company_id"
    t.index ["driver_id"], name: "index_vehicles_on_driver_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "expense_records", "trips"
  add_foreign_key "fuel_records", "trips"
  add_foreign_key "shift_assignments", "users", column: "driver_id"
  add_foreign_key "shift_assignments", "vehicles"
  add_foreign_key "trips", "companies"
  add_foreign_key "users", "companies"
  add_foreign_key "vehicles", "companies"
  add_foreign_key "vehicles", "users", column: "driver_id"
end
