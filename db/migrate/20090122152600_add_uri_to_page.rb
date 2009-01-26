class AddUriToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :url_override, :string
  end

  def self.down
    remove_column :pages, :url_override
  end
end
