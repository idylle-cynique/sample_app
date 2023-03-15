class Hoge
  attr_accessor :foobar, :nootbar

  def initialize
    foobar = "foobar"
    nootbar = "nootbar"
  end

  def nootbaz
    self.nootbar = "nootbaz" and return true
  end
end
hoge = Hoge.new
puts "
#{hoge}
#{hoge.foobar.inspect}
#{hoge.nootbar.inspect}
#{hoge.nootbaz}
#{hoge.nootbar}
"
