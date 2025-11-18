# frozen_string_literal: true

class AddPostalToCard < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :postal, :string
  end
end
