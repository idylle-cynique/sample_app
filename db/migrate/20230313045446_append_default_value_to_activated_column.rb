class AppendDefaultValueToActivatedColumn < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :activated, from: nil, to: false
  end
end
