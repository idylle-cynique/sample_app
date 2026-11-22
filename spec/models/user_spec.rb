# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "有効性" do
    context "全属性が有効な場合" do
      it "有効な属性のとき、有効になる" do
        expect(build(:user)).to be_valid
      end
    end
  end

  describe "名前のバリデーション" do
    context "必須入力を検証する場合" do
      it "名前が空のとき、ユーザーが無効になる" do
        user = build(:user, name: "")

        expect(user).to be_invalid
        expect(user.errors.details[:name].first[:error]).to eq(:blank)
      end
    end

    context "文字数を検証する場合" do
      it "50文字のとき、有効になる" do
        expect(build(:user, name: "a" * 50)).to be_valid
      end

      it "51文字のとき、無効になる" do
        user = build(:user, name: "a" * 51)

        expect(user).to be_invalid
        expect(user.errors.details[:name].first[:error]).to eq(:too_long)
      end
    end
  end

  describe "メールアドレスのバリデーション" do
    context "必須入力を検証する場合" do
      it "未入力のとき、ユーザーが無効になる" do
        user = build(:user, email: "")

        expect(user).to be_invalid
        expect(user.errors.details[:email].first[:error]).to eq(:blank)
      end
    end

    context "文字数を検証する場合" do
      it "255文字のとき、有効になる" do
        email = "#{'a' * 243}@example.com"

        expect(build(:user, email: email)).to be_valid
      end

      it "256文字のとき、無効になる" do
        email = "#{'a' * 244}@example.com"
        user = build(:user, email: email)

        expect(user).to be_invalid
        expect(user.errors.details[:email].first[:error]).to eq(:too_long)
      end
    end

    context "形式を検証する場合" do
      it "有効な形式のとき、ユーザーが有効になる" do
        expect(build(:user, email: "user@example.com")).to be_valid
      end

      it "不正な形式のとき、ユーザーが無効になる" do
        ["user", "user@", "user name@example.com"].each do |email|
          expect(build(:user, email: email)).to be_invalid
        end
      end
    end

    context "一意性を検証する場合" do
      it "大文字小文字だけが異なる重複アドレスのとき、ユーザーが無効になる" do
        create(:user, email: "User@example.com")
        duplicate = build(:user, email: "user@example.com")

        expect(duplicate).to be_invalid
        expect(duplicate.errors.details[:email].first[:error]).to eq(:taken)
      end
    end
  end

  describe "メールアドレスの正規化" do
    context "大文字を含むアドレスを保存する場合" do
      it "保存したとき、小文字に変換される" do
        user = create(:user, email: "User@Example.COM")

        expect(user.reload.email).to eq("user@example.com")
      end
    end
  end

  describe "パスワードのバリデーション" do
    context "必須入力を検証する場合" do
      it "未入力のとき、ユーザーが無効になる" do
        user = build(:user, password: "", password_confirmation: "")

        expect(user).to be_invalid
        expect(user.errors.details[:password].first[:error]).to eq(:blank)
      end
    end

    context "最小文字数を検証する場合" do
      it "5文字のとき、ユーザーが無効になる" do
        user = build(:user, password: "12345", password_confirmation: "12345")

        expect(user).to be_invalid
      end

      it "6文字のとき、ユーザーが有効になる" do
        user = build(:user, password: "123456", password_confirmation: "123456")

        expect(user).to be_valid
      end

      it "6文字が空白のみのとき、ユーザーが無効になる" do
        user = build(:user, password: " " * 6, password_confirmation: " " * 6)

        expect(user).to be_invalid
      end
    end

    context "確認用パスワードを検証する場合" do
      it "確認用パスワードが一致しないとき、ユーザーが無効になる" do
        user = build(:user, password_confirmation: "different")

        expect(user).to be_invalid
        expect(user.errors.details[:password_confirmation].first[:error]).to eq(:confirmation)
      end
    end
  end
end
