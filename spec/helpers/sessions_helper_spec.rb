# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsHelper do
  let(:user) { create(:user, activated: true) }

  describe "#current_user?" do
    context "セッショントークンが一致している場合" do
      before do
        helper.log_in(user)
      end

      it "本人を現在のユーザーと判定する" do
        expect(helper.current_user?(user)).to be(true)
      end

      it "別のユーザーを現在のユーザーと判定しない" do
        expect(helper.current_user?(create(:user))).to be(false)
      end
    end

    it "ゲストには現在のユーザーがいない" do
      expect(helper.current_user?(user)).to be(false)
    end

    it "トークンが双方で未設定ならユーザー ID があっても認証しない" do
      helper.session[:user_id] = user.id

      expect(helper.current_user).to be_nil
    end
  end
end
