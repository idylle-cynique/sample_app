require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  BASE_TITLE = 'Ruby on Rails Tutorial Sample App'.freeze

  test 'full_title は引数なしの場合ベースタイトルのみを返す' do
    assert_equal BASE_TITLE, full_title
  end

  test 'full_title は引数が空文字の場合ベースタイトルのみを返す' do
    assert_equal BASE_TITLE, full_title('')
  end

  test 'full_title は引数がある場合「引数 | ベースタイトル」を返す' do
    assert_equal "Help | #{BASE_TITLE}", full_title('Help')
  end
end
