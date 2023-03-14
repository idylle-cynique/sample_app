class Hoge
  def foobar
    true
  end

  def nootbar
    true
  end
end

hoge = Hoge.new

p "いいぞ。" if hoge && hoge.foobar && hoge.nootbar

p "ヨシ！" if hoge&.foobar && hoge&.nootbar
p "ヨシ！(ヨシじゃない)" if hoge&.foobar && !hoge&.nootbar

# エラー p "だめです。" if hoge&(.foobar && .nootbar)
# エラー p "だめです。" if hoge&.(foobar && nootbar)


# p (hoge&.(foobar&&nootbar))
