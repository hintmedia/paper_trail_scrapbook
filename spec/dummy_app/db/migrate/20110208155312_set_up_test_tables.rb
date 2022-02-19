# Parts of this migration must be kept in sync with
# `lib/generators/paper_trail/templates/create_versions.rb`
#
# Starting with AR 5.1, we must specify which version of AR we are using.
# I tried using `const_get` but I got a `NameError`, then I learned about
# `::ActiveRecord::Migration::Current`.
class SetUpTestTables < (
  if ::ActiveRecord::VERSION::MAJOR >= 5
    ::ActiveRecord::Migration::Current
  else
    ::ActiveRecord::Migration
  end
)
  MYSQL_ADAPTERS = %w[ActiveRecord::ConnectionAdapters::MysqlAdapter ActiveRecord::ConnectionAdapters::Mysql2Adapter].freeze
  TEXT_BYTES = 1_073_741_823

  def up
    create_table :on_create, force: true do |t|
      t.string :name, null: false
    end

    create_table :on_destroy, force: true do |t|
      t.string :name, null: false
    end

    create_table :on_empty_array, force: true do |t|
      t.string :name, null: false
    end

    create_table :on_update, force: true do |t|
      t.string :name, null: false
    end

    # Classes: Vehicle, Car, Truck
    create_table :vehicles, force: true do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.timestamps null: false
    end

    create_table :skippers, force: true do |t|
      t.string     :name
      t.datetime   :another_timestamp
      t.timestamps null: true
    end

    create_table :widgets, force: true do |t|
      t.string    :name
      t.text      :a_text
      t.integer   :an_integer
      t.float     :a_float
      t.decimal   :a_decimal, precision: 6, scale: 4
      t.datetime  :a_datetime
      t.time      :a_time
      t.date      :a_date
      t.boolean   :a_boolean
      t.string    :type
      t.timestamps null: true
    end

    create_table :versions, **versions_table_options do |t|
      t.string   :item_type, item_type_options
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object, limit: TEXT_BYTES
      t.text     :object_changes, limit: TEXT_BYTES
      t.integer  :transaction_id
      t.datetime :created_at

      # Metadata columns.
      t.integer :answer
      t.string :action
      t.string  :question
      t.integer :article_id
      t.string :title

      # Controller info columns.
      t.string :ip
      t.string :user_agent
    end
    add_index :versions, %i[item_type item_id]

    create_table :version_associations do |t|
      t.integer  :version_id
      t.string   :foreign_key_name, null: false
      t.integer  :foreign_key_id
    end
    add_index :version_associations, [:version_id]
    add_index :version_associations,
              %i[foreign_key_name foreign_key_id],
              name: 'index_version_associations_on_foreign_key'

    create_table :post_versions, force: true do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at

      # Controller info columns.
      t.string :ip
      t.string :user_agent
    end
    add_index :post_versions, %i[item_type item_id]

    if ENV['DB'] == 'postgres' && ::ActiveRecord::VERSION::MAJOR >= 4
      create_table :json_versions, force: true do |t|
        t.string   :item_type, null: false
        t.integer  :item_id,   null: false
        t.string   :event,     null: false
        t.string   :whodunnit
        t.json     :object
        t.json     :object_changes
        t.datetime :created_at
      end
      add_index :json_versions, %i[item_type item_id]
    end

    create_table :not_on_updates, force: true do |t|
      t.timestamps null: true
    end

    create_table :bananas, force: true do |t|
      t.timestamps null: true
    end

    create_table :banana_versions, force: true do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :banana_versions, %i[item_type item_id]

    create_table :wotsits, force: true do |t|
      t.integer :widget_id
      t.string  :name
      t.timestamps null: true
    end

    create_table :fluxors, force: true do |t|
      t.integer :widget_id
      t.string  :name
    end

    create_table :whatchamajiggers, force: true do |t|
      t.string  :owner_type
      t.integer :owner_id
      t.string  :name
    end

    create_table :articles, force: true do |t|
      t.string :title
      t.string :content
      t.string :abstract
      t.string :file_upload
    end

    create_table :books, force: true do |t|
      t.string :title
    end

    create_table :authorships, force: true do |t|
      t.integer :book_id
      t.integer :author_id
    end

    create_table :people, force: true do |t|
      t.string :name
      t.string :time_zone
      t.integer :mentor_id
    end

    create_table :editorships, force: true do |t|
      t.integer :book_id
      t.integer :editor_id
    end

    create_table :editors, force: true do |t|
      t.string :name
    end

    create_table :songs, force: true do |t|
      t.integer :length
    end

    create_table :posts, force: true do |t|
      t.string :title
      t.string :content
    end

    create_table :post_with_statuses, force: true do |t|
      t.integer :status
      t.timestamps null: false
    end

    create_table :animals, force: true do |t|
      t.string :name
      t.string :species # single table inheritance column
    end

    create_table :documents, force: true do |t|
      t.string :name
    end

    create_table :legacy_widgets, force: true do |t|
      t.string    :name
      t.integer   :version
    end

    create_table :things, force: true do |t|
      t.string    :name
    end

    create_table :translations, force: true do |t|
      t.string    :headline
      t.string    :content
      t.string    :language_code
      t.string    :type
    end

    create_table :gadgets, force: true do |t|
      t.string    :name
      t.string    :brand
      t.timestamps null: true
    end

    create_table :customers, force: true do |t|
      t.string :name
    end

    create_table :orders, force: true do |t|
      t.integer :customer_id
      t.string  :order_date
    end

    create_table :line_items, force: true do |t|
      t.integer :order_id
      t.string  :product
    end

    create_table :fruits, force: true do |t|
      t.string :name
      t.string :color
    end

    create_table :boolits, force: true do |t|
      t.string :name
      t.boolean :scoped, default: true
    end

    create_table :callback_modifiers, force: true do |t|
      t.string  :some_content
      t.boolean :deleted, default: false
    end

    create_table :chapters, force: true do |t|
      t.string :name
    end

    create_table :sections, force: true do |t|
      t.integer :chapter_id
      t.string :name
    end

    create_table :paragraphs, force: true do |t|
      t.integer :section_id
      t.string :name
    end

    create_table :quotations, force: true do |t|
      t.integer :chapter_id
    end

    create_table :citations, force: true do |t|
      t.integer :quotation_id
    end

    create_table :foo_habtms, force: true do |t|
      t.string :name
    end

    create_table :bar_habtms, force: true do |t|
      t.string :name
    end

    create_table :bar_habtms_foo_habtms, force: true, id: false do |t|
      t.integer :foo_habtm_id
      t.integer :bar_habtm_id
    end
    add_index :bar_habtms_foo_habtms, [:foo_habtm_id]
    add_index :bar_habtms_foo_habtms, [:bar_habtm_id]

    # custom_primary_key_records use a uuid column (string)
    create_table :custom_primary_key_records, id: false, force: true do |t|
      t.column :uuid, :string, primary_key: true
      t.string :name
      t.timestamps null: true
    end

    # and custom_primary_key_record_versions stores the uuid in item_id, a string
    create_table :custom_primary_key_record_versions, force: true do |t|
      t.string   :item_type, null: false
      t.string   :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :custom_primary_key_record_versions, %i[item_type item_id], name: 'idx_cust_pk_item'
  end

  def down
    # Not actually irreversible, but there is no need to maintain this method.
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def item_type_options
    opt = { null: false }
    opt[:limit] = 191 if mysql?
    opt
  end

  def mysql?
    MYSQL_ADAPTERS.include?(connection.class.name)
  end

  def versions_table_options
    if mysql?
      { options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci' }
    else
      {}
    end
  end
end
