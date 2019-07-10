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

ActiveRecord::Schema.define(version: 20181001083021) do

  create_table "accounts", force: :cascade do |t|
    t.string   "first_name",              limit: 150
    t.string   "last_name",               limit: 150
    t.string   "email",                   limit: 255
    t.string   "encrypted_password",      limit: 255, default: "",   null: false
    t.string   "role",                    limit: 255
    t.integer  "contractor_id",           limit: 4
    t.string   "locale",                  limit: 255, default: "en", null: false
    t.string   "mobile_number",           limit: 255
    t.boolean  "subscribe_newsletter",                default: true, null: false
    t.string   "reset_password_token",    limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "suspended_at"
    t.integer  "account_id",              limit: 4
    t.integer  "no_of_account",           limit: 4
    t.string   "uid",                     limit: 255
    t.string   "provider",                limit: 255
    t.integer  "property_agent_id",       limit: 4
    t.string   "cea_number",              limit: 255
    t.integer  "facilities_manager_id",   limit: 4
    t.integer  "country_id",              limit: 4
    t.string   "email_verification_code", limit: 255
    t.string   "confirmation_token",      limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",       limit: 255
    t.boolean  "agent"
    t.string   "partner_code",            limit: 255
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",   limit: 4
  end

  create_table "bids", force: :cascade do |t|
    t.integer  "job_id",        limit: 4
    t.integer  "contractor_id", limit: 4
    t.decimal  "amount",                    precision: 13, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency",      limit: 255
    t.boolean  "accept"
    t.decimal  "amount_quoter",             precision: 10,           default: 0
    t.string   "file",          limit: 255
  end

  create_table "budgets", force: :cascade do |t|
    t.decimal  "start_price", precision: 10,           null: false
    t.decimal  "end_price",   precision: 10,           null: false
    t.decimal  "lead_price",  precision: 5,  scale: 2, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug_url",   limit: 255
  end

  create_table "cities", force: :cascade do |t|
    t.integer "country_id", limit: 4
    t.string  "name",       limit: 255
    t.boolean "available"
    t.boolean "commercial"
  end

  add_index "cities", ["name"], name: "index_cities_on_name", using: :btree

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size",    limit: 4
    t.integer  "assetable_id",      limit: 4
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "clarifications", force: :cascade do |t|
    t.integer  "job_id",        limit: 4,   null: false
    t.integer  "contractor_id", limit: 4,   null: false
    t.string   "question",      limit: 255
    t.string   "answer",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "company_brochures", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4
    t.string   "file",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "company_projects", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4
    t.string   "file",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "contractors", force: :cascade do |t|
    t.string   "company_name",                 limit: 255,                   null: false
    t.string   "company_street_no",            limit: 255
    t.string   "company_street_name",          limit: 255
    t.string   "company_unit_no",              limit: 255
    t.string   "company_building_name",        limit: 255
    t.string   "company_postal_code",          limit: 255
    t.string   "company_name_slug",            limit: 255,                   null: false
    t.string   "company_logo",                 limit: 255
    t.string   "nric_no",                      limit: 255
    t.string   "uen_number",                   limit: 255
    t.string   "bca_license",                  limit: 255
    t.string   "hdb_license",                  limit: 255
    t.string   "billing_name",                 limit: 255
    t.text     "billing_address",              limit: 65535
    t.string   "billing_postal_code",          limit: 255
    t.string   "billing_phone_no",             limit: 255
    t.boolean  "mobile_alerts",                              default: true,  null: false
    t.boolean  "email_alerts",                               default: true,  null: false
    t.integer  "score",                        limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "company_description",          limit: 65535
    t.string   "pub_license",                  limit: 255
    t.string   "ema_license",                  limit: 255
    t.string   "case_member",                  limit: 255
    t.string   "scal_member",                  limit: 255
    t.string   "bizsafe_member",               limit: 255
    t.string   "selected_header_image",        limit: 255
    t.string   "crop_x",                       limit: 255
    t.string   "crop_y",                       limit: 255
    t.string   "crop_w",                       limit: 255
    t.string   "crop_h",                       limit: 255
    t.integer  "parent_id",                    limit: 4
    t.integer  "sms_count",                    limit: 4
    t.boolean  "is_deactivated"
    t.string   "office_number",                limit: 255
    t.boolean  "verified"
    t.string   "photo_id",                     limit: 255
    t.string   "business_registration",        limit: 255
    t.integer  "bids_count",                   limit: 4,     default: 0
    t.float    "average_rating",               limit: 24,    default: 0.0
    t.boolean  "approved",                                   default: false
    t.boolean  "commercial",                                 default: false, null: false
    t.boolean  "accept_agreement"
    t.datetime "company_red"
    t.string   "company_rn",                   limit: 255
    t.string   "company_rd",                   limit: 255
    t.datetime "date_incor"
    t.string   "relevant_activitie",           limit: 255
    t.string   "association_name",             limit: 255
    t.string   "membership_no",                limit: 255
    t.string   "financial_report",             limit: 255
    t.string   "bank_statement",               limit: 255
    t.boolean  "legal"
    t.string   "legal_text",                   limit: 255
    t.boolean  "request_commercial",                         default: false
    t.boolean  "verification_request",                       default: false
    t.datetime "commercial_registration_date"
  end

  create_table "contractors_cities", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4
    t.integer  "city_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contractors_skills", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4
    t.integer  "skill_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contractors_work_locations", force: :cascade do |t|
    t.integer  "contractor_id",    limit: 4
    t.integer  "work_location_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: :cascade do |t|
    t.string  "name",                           limit: 255
    t.string  "native_name",                    limit: 255
    t.string  "cca2",                           limit: 255
    t.string  "cca3",                           limit: 255
    t.string  "flag",                           limit: 255
    t.string  "currency_code",                  limit: 255
    t.string  "price_format",                   limit: 255
    t.string  "default_phone_code",             limit: 255
    t.boolean "available"
    t.string  "time_zone",                      limit: 255
    t.text    "top_up_amounts",                 limit: 65535
    t.decimal "sms_bundle_price",                             precision: 13, scale: 2, default: 9.99
    t.boolean "postal_codes",                                                          default: true
    t.boolean "paypal",                                                                default: false
    t.boolean "braintree",                                                             default: false
    t.string  "default_locale",                 limit: 255,                            default: "en"
    t.boolean "commercial",                                                            default: false
    t.decimal "residential_subscription_price",               precision: 13, scale: 2, default: 0.0
    t.decimal "commercial_subscription_price",                precision: 13, scale: 2, default: 0.0
    t.boolean "subscription_flag",                                                     default: false
  end

  add_index "countries", ["name"], name: "index_countries_on_name", using: :btree

  create_table "countries_budgets", force: :cascade do |t|
    t.integer  "country_id",  limit: 4
    t.integer  "budget_id",   limit: 4
    t.decimal  "start_price",           precision: 13
    t.decimal  "end_price",             precision: 13
    t.decimal  "lead_price",            precision: 13, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries_landing_pages", id: false, force: :cascade do |t|
    t.integer "country_id",      limit: 4
    t.integer "landing_page_id", limit: 4
  end

  add_index "countries_landing_pages", ["country_id", "landing_page_id"], name: "index_countries_landing_pages_on_country_id_and_landing_page_id", using: :btree
  add_index "countries_landing_pages", ["country_id"], name: "index_countries_landing_pages_on_country_id", using: :btree

  create_table "countries_posts", force: :cascade do |t|
    t.integer  "country_id", limit: 4
    t.integer  "post_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries_posts", ["country_id", "post_id"], name: "index_countries_posts_on_country_id_and_post_id", using: :btree
  add_index "countries_posts", ["country_id"], name: "index_countries_posts_on_country_id", using: :btree

  create_table "credits", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4
    t.decimal  "amount",                    precision: 13, scale: 2,                 null: false
    t.string   "deposit_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "discount",                  precision: 10
    t.string   "currency",      limit: 255,                          default: "sgd"
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.string   "token",      limit: 255
    t.string   "platform",   limit: 255
    t.boolean  "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feature_payments", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4
    t.decimal  "amount",                    precision: 13, scale: 2, null: false
    t.string   "feature_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fees", force: :cascade do |t|
    t.integer  "country_id", limit: 4
    t.integer  "commission", limit: 4,                default: 10
    t.decimal  "concierge",            precision: 10, default: 0
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "sender_id",          limit: 4
    t.string   "sender_type",        limit: 255
    t.integer  "recipient_id",       limit: 4
    t.string   "recipient_type",     limit: 255
    t.integer  "job_id",             limit: 4
    t.decimal  "amount",                         precision: 15, scale: 2
    t.string   "currency",           limit: 255
    t.string   "number",             limit: 255
    t.string   "file",               limit: 255
    t.boolean  "paid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commission",         limit: 4
    t.decimal  "concierge",                      precision: 10
    t.integer  "partner_commission", limit: 4,                            default: 0
  end

  create_table "job_categories", force: :cascade do |t|
    t.string   "name",        limit: 255,                  null: false
    t.text     "description", limit: 65535
    t.integer  "skill_id",    limit: 4,                    null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "min_budget",                precision: 10, null: false
    t.decimal  "max_budget",                precision: 10
  end

  create_table "job_views", force: :cascade do |t|
    t.integer  "job_id",        limit: 4
    t.integer  "contractor_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: :cascade do |t|
    t.integer  "homeowner_id",              limit: 4
    t.integer  "contractor_id",             limit: 4
    t.integer  "job_category_id",           limit: 4
    t.integer  "skill_id",                  limit: 4
    t.integer  "work_location_id",          limit: 4
    t.integer  "budget_id",                 limit: 4
    t.text     "description",               limit: 65535,                                                        null: false
    t.integer  "availability_id",           limit: 4
    t.string   "postal_code",               limit: 255
    t.decimal  "lat",                                     precision: 15, scale: 10
    t.decimal  "lng",                                     precision: 15, scale: 10
    t.string   "state",                     limit: 255,                             default: "pending"
    t.datetime "purchased_at"
    t.datetime "approved_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contact_time_id",           limit: 4,                               default: 0,                  null: false
    t.datetime "archived_at"
    t.integer  "property_type",             limit: 4
    t.string   "code",                      limit: 255
    t.string   "image",                     limit: 255
    t.integer  "priority_level",            limit: 4
    t.integer  "specific_contractor_id",    limit: 4
    t.boolean  "require_renovation_loan"
    t.string   "ref_code",                  limit: 255
    t.integer  "city_id",                   limit: 4
    t.string   "client_type",               limit: 255
    t.integer  "renovation_type",           limit: 4
    t.integer  "floor_size",                limit: 4
    t.string   "client_type_code",          limit: 255
    t.boolean  "concierge_service",                                                 default: true
    t.string   "address",                   limit: 255
    t.decimal  "budget_value",                            precision: 30, scale: 10
    t.string   "type",                      limit: 255,                             default: "Residential::Job"
    t.datetime "start_date"
    t.integer  "commission_rate",           limit: 4,                               default: 10,                 null: false
    t.decimal  "concierges_service_amount",               precision: 10,            default: 20
    t.integer  "number_of_quote",           limit: 4,                               default: 0
    t.string   "client_first_name",         limit: 150
    t.string   "client_last_name",          limit: 150
    t.string   "client_email",              limit: 255
    t.string   "client_mobile_number",      limit: 20
    t.string   "partner_code",              limit: 255
    t.integer  "partner_id",                limit: 4
  end

  add_index "jobs", ["state"], name: "index_jobs_on_state", using: :btree

  create_table "landing_page_categories", force: :cascade do |t|
    t.string "name",  limit: 255
    t.string "image", limit: 255
  end

  create_table "landing_pages", force: :cascade do |t|
    t.string   "title",                    limit: 255
    t.string   "header",                   limit: 255
    t.string   "description",              limit: 255
    t.string   "keywords",                 limit: 255
    t.string   "slug",                     limit: 255
    t.text     "content",                  limit: 65535
    t.string   "banner",                   limit: 255
    t.integer  "skill_id",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer  "landing_page_category_id", limit: 4
    t.string   "language",                 limit: 255,   default: "en"
    t.boolean  "visible_all_countries",                  default: true
  end

  add_index "landing_pages", ["landing_page_category_id"], name: "index_landing_pages_on_landing_page_category_id", using: :btree
  add_index "landing_pages", ["language"], name: "index_landing_pages_on_language", using: :btree
  add_index "landing_pages", ["published_at"], name: "index_landing_pages_on_published_at", using: :btree

  create_table "legal_documents", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.string   "slug",            limit: 255
    t.text     "content",         limit: 4294967295
    t.string   "seo_description", limit: 255
    t.string   "seo_keywords",    limit: 255
    t.string   "language",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meetings", force: :cascade do |t|
    t.integer  "job_id",        limit: 4,   null: false
    t.integer  "contractor_id", limit: 4,   null: false
    t.date     "date"
    t.time     "time"
    t.string   "place",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accept"
    t.integer  "homeowner_id",  limit: 4
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4,   null: false
    t.integer  "plan_id",       limit: 4,   null: false
    t.string   "paypal_txn_id", limit: 255
    t.datetime "expires_on",                null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paypal_payments", force: :cascade do |t|
    t.integer  "contractor_id",             limit: 4
    t.integer  "membership_id",             limit: 4
    t.string   "txn_id",                    limit: 255
    t.string   "txn_type",                  limit: 255
    t.decimal  "amount",                                  precision: 13, scale: 2
    t.decimal  "fee",                                     precision: 12, scale: 2
    t.string   "currency",                  limit: 255
    t.string   "status",                    limit: 255
    t.string   "type",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "params",                    limit: 65535
    t.string   "braintree_subscription_id", limit: 255
    t.integer  "payment_type",              limit: 4,                              null: false
  end

  create_table "phone_verifications", force: :cascade do |t|
    t.integer  "account_id",                   limit: 4
    t.string   "mobile_number",                limit: 255
    t.string   "verification_code",            limit: 255
    t.datetime "verification_code_expires_at"
    t.string   "ip",                           limit: 255
    t.boolean  "verified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: :cascade do |t|
    t.string   "image_name",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contractor_id", limit: 255
    t.string   "job_id",        limit: 255
  end

  create_table "post_categories", force: :cascade do |t|
    t.integer  "post_id",     limit: 4
    t.integer  "category_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title",                  limit: 255
    t.text     "body",                   limit: 65535
    t.text     "meta_keyword",           limit: 65535
    t.text     "meta_description",       limit: 65535
    t.integer  "category_id",            limit: 4
    t.string   "image",                  limit: 255
    t.string   "author",                 limit: 255
    t.string   "author_google_plus_url", limit: 255
    t.boolean  "is_published"
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.string   "slug_url",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "post_type",              limit: 255
    t.integer  "parent_id",              limit: 4
    t.integer  "account_id",             limit: 4
    t.boolean  "anonymous"
    t.integer  "children_count",         limit: 4,     default: 0,         null: false
    t.string   "state",                  limit: 255,   default: "pending", null: false
    t.integer  "votes_count",            limit: 4,     default: 0
    t.integer  "country_id",             limit: 4
    t.boolean  "visible_all_countries",                default: true
  end

  add_index "posts", ["account_id"], name: "index_posts_on_account_id", using: :btree

  create_table "punches", force: :cascade do |t|
    t.integer  "punchable_id",   limit: 4,              null: false
    t.string   "punchable_type", limit: 20,             null: false
    t.datetime "starts_at",                             null: false
    t.datetime "ends_at",                               null: false
    t.datetime "average_time",                          null: false
    t.integer  "hits",           limit: 4,  default: 1, null: false
  end

  add_index "punches", ["average_time"], name: "index_punches_on_average_time", using: :btree
  add_index "punches", ["punchable_type", "punchable_id"], name: "punchable_index", using: :btree

  create_table "questions", force: :cascade do |t|
    t.integer "account_id", limit: 4
    t.string  "name",       limit: 255
    t.string  "email",      limit: 255
    t.text    "question",   limit: 65535
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "job_id",          limit: 4,                                         null: false
    t.integer  "contractor_id",   limit: 4,                                         null: false
    t.integer  "professionalism", limit: 4,                             default: 0, null: false
    t.integer  "quality",         limit: 4,                             default: 0, null: false
    t.integer  "value",           limit: 4,                             default: 0, null: false
    t.text     "comments",        limit: 65535
    t.decimal  "score",                         precision: 5, scale: 2
    t.datetime "approved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repost_jobs", force: :cascade do |t|
    t.integer  "old_job_id", limit: 4
    t.integer  "new_job_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "revenues", force: :cascade do |t|
    t.datetime "time"
    t.float    "amount",     limit: 24
    t.integer  "country_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.text     "description", limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "contractor_id",           limit: 4
    t.datetime "expired_at"
    t.boolean  "auto_reload",                                                  default: false
    t.integer  "category",                limit: 4
    t.string   "currency",                limit: 255
    t.decimal  "price",                               precision: 13, scale: 2, default: 0.0
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.integer  "subscription_payment_id", limit: 4
  end

  create_table "votes", force: :cascade do |t|
    t.integer "account_id", limit: 4
    t.integer "post_id",    limit: 4
  end

  add_index "votes", ["account_id"], name: "index_votes_on_account_id", using: :btree
  add_index "votes", ["post_id"], name: "index_votes_on_post_id", using: :btree

  create_table "waiting_lists", force: :cascade do |t|
    t.integer  "contractor_id", limit: 4, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_foreign_key "posts", "accounts"
  add_foreign_key "votes", "accounts"
  add_foreign_key "votes", "posts"
end
