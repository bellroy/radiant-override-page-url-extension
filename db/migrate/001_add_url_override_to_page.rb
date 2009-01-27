class AddUrlOverrideToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :url_override, :string
    add_index  :pages, :url_override
  end

  def self.down
    remove_column :pages, :url_override
    remove_index  :pages, :url_override
  end
end
