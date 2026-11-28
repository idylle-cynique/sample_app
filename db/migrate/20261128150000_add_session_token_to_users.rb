class AddSessionTokenToUsers < ActiveRecord::Migration[8.1]
  # 既存のセッションで使われている値を新しい列へ引き継ぐ。
  def up
    add_column :users, :session_token, :string
    execute "UPDATE users SET session_token = remember_digest WHERE remember_digest IS NOT NULL"
  end

  # 旧コードがセッション認証に使う記憶ダイジェストの列を残す。
  def down
    remove_column :users, :session_token
  end
end
