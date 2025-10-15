class CreateIdentities < ActiveRecord::Migration[8.0]
  def change
    create_table :identities do |t|
      t.string :uid
      t.string :provider
      t.references :user, null: false

      t.timestamps
    end
  end
end
