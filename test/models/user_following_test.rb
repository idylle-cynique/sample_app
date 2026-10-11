require 'test_helper'

class UserFollowingTest < ActiveSupport::TestCase
  test 'follow は未フォローのユーザーを following に、自分を相手の followers に追加する' do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following.include?(archer)
    michael.follow(archer)
    assert michael.following.include?(archer)
    assert archer.followers.include?(michael)
  end

  test 'follow は自分自身をフォローしない' do
    michael = users(:michael)
    assert_no_difference 'Relationship.count' do
      michael.follow(michael)
    end
    assert_not michael.following.include?(michael)
  end

  test 'unfollow はフォロー中のユーザーを following から削除する' do
    michael = users(:michael)
    lana = users(:lana)
    assert michael.following.include?(lana)
    michael.unfollow(lana)
    assert_not michael.following.include?(lana)
  end

  test 'following? はフォロー中のユーザーなら true を返す' do
    assert users(:michael).following?(users(:lana))
  end

  test 'following? は未フォローのユーザーなら false を返す' do
    assert_not users(:michael).following?(users(:archer))
  end

  test 'feed は自分の投稿を含む' do
    assert_includes users(:michael).feed, microposts(:orange)
  end

  test 'feed はフォロー中のユーザーの投稿を含む' do
    assert_includes users(:michael).feed, microposts(:tone)
  end

  test 'feed は未フォローのユーザーの投稿を含まない' do
    assert_not_includes users(:michael).feed, microposts(:ants)
  end
end
