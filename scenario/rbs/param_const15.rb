## update: test.rbs
class C
  def foo: (const Integer, String) -> Integer
end

## update: test.rb
class C
  def foo(n, m)
    n + m.length
  end
end

## assert: test.rb
class C
  def foo: (const Integer, String) -> Integer
end
