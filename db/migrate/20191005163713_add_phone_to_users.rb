# frozen_string_literal: true

class AddPhoneToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :phone, :string
  end
end
