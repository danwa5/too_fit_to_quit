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

ActiveRecord::Schema.define(version: 20180311063609) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_fitbit_runs", force: :cascade do |t|
    t.integer  "user_id",          null: false
    t.integer  "activity_type_id"
    t.integer  "avg_heart_rate"
    t.integer  "steps"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.json     "tcx_data"
    t.json     "gps_data"
    t.string   "city"
    t.string   "state_province"
    t.string   "country"
  end

  add_index "activity_fitbit_runs", ["user_id"], name: "index_activity_fitbit_runs_on_user_id", using: :btree

  create_table "activity_strava_runs", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.decimal  "total_elevation_gain"
    t.decimal  "elevation_high"
    t.decimal  "elevation_low"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.json     "splits"
    t.decimal  "start_latitude"
    t.decimal  "start_longitude"
    t.string   "city"
    t.string   "state_province"
    t.string   "country"
  end

  add_index "activity_strava_runs", ["user_id"], name: "index_activity_strava_runs_on_user_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.string   "uid"
    t.string   "provider"
    t.string   "access_token"
    t.string   "refresh_token"
    t.integer  "expires_at"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "time_zone"
  end

  create_table "user_activities", force: :cascade do |t|
    t.integer  "user_id",                  null: false
    t.integer  "activity_id"
    t.string   "activity_type"
    t.string   "uid",                      null: false
    t.decimal  "distance"
    t.integer  "duration"
    t.datetime "start_time"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.json     "activity_data"
    t.integer  "start_time_rounded_epoch"
    t.string   "state"
  end

  add_index "user_activities", ["activity_type", "activity_id"], name: "index_user_activities_on_activity_type_and_activity_id", using: :btree
  add_index "user_activities", ["user_id", "activity_type", "activity_id"], name: "index_user_and_activity", unique: true, using: :btree
  add_index "user_activities", ["user_id", "activity_type", "uid"], name: "index_user_activities_on_user_id_and_activity_type_and_uid", unique: true, using: :btree
  add_index "user_activities", ["user_id", "start_time_rounded_epoch"], name: "index_user_activities_on_user_id_and_start_time_rounded_epoch", using: :btree
  add_index "user_activities", ["user_id"], name: "index_user_activities_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "activity_fitbit_runs", "users"
  add_foreign_key "activity_strava_runs", "users"
  add_foreign_key "user_activities", "users"
end
