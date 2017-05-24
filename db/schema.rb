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

ActiveRecord::Schema.define(version: 20160328144448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "account_majors", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "major_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "account_majors", ["account_id"], name: "index_account_majors_on_account_id", using: :btree
  add_index "account_majors", ["major_id"], name: "index_account_majors_on_major_id", using: :btree

  create_table "account_minors", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "minor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "account_minors", ["account_id"], name: "index_account_minors_on_account_id", using: :btree
  add_index "account_minors", ["minor_id"], name: "index_account_minors_on_minor_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "student_id"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "edu_email"
    t.date     "graduation_date"
    t.text     "about_me"
    t.string   "facebook_link"
    t.string   "twitter_link"
    t.string   "avatar"
    t.integer  "cached_votes_total", default: 0
    t.integer  "cached_votes_score", default: 0
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
    t.string   "gpa"
    t.string   "school"
    t.string   "graduation_year"
  end

  add_index "accounts", ["cached_votes_down"], name: "index_accounts_on_cached_votes_down", using: :btree
  add_index "accounts", ["cached_votes_score"], name: "index_accounts_on_cached_votes_score", using: :btree
  add_index "accounts", ["cached_votes_total"], name: "index_accounts_on_cached_votes_total", using: :btree
  add_index "accounts", ["cached_votes_up"], name: "index_accounts_on_cached_votes_up", using: :btree
  add_index "accounts", ["student_id"], name: "index_accounts_on_student_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "followable_id",                   null: false
    t.string   "followable_type",                 null: false
    t.integer  "follower_id",                     null: false
    t.string   "follower_type",                   null: false
    t.boolean  "blocked",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "majors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "minors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "papers", force: :cascade do |t|
    t.string   "title"
    t.string   "file"
    t.integer  "account_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "cached_votes_total", default: 0
    t.integer  "cached_votes_score", default: 0
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
    t.text     "about"
    t.string   "themes"
    t.date     "date_of_creating"
    t.string   "professor"
    t.string   "grade"
  end

  add_index "papers", ["account_id"], name: "index_papers_on_account_id", using: :btree
  add_index "papers", ["cached_votes_down"], name: "index_papers_on_cached_votes_down", using: :btree
  add_index "papers", ["cached_votes_score"], name: "index_papers_on_cached_votes_score", using: :btree
  add_index "papers", ["cached_votes_total"], name: "index_papers_on_cached_votes_total", using: :btree
  add_index "papers", ["cached_votes_up"], name: "index_papers_on_cached_votes_up", using: :btree

  create_table "research_interests", force: :cascade do |t|
    t.string   "title"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "research_interests", ["account_id"], name: "index_research_interests_on_account_id", using: :btree

  create_table "students", force: :cascade do |t|
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
    t.string   "uid"
    t.string   "provider"
  end

  add_index "students", ["email"], name: "index_students_on_email", unique: true, using: :btree
  add_index "students", ["reset_password_token"], name: "index_students_on_reset_password_token", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "account_majors", "accounts"
  add_foreign_key "account_majors", "majors"
  add_foreign_key "account_minors", "accounts"
  add_foreign_key "account_minors", "minors"
  add_foreign_key "accounts", "students"
  add_foreign_key "papers", "accounts"
  add_foreign_key "research_interests", "accounts"
end
