## update: test.rbs
class C
  def foo: (String, const String) -> Integer
end

## update: test.rb
class C
  def foo(n, m)
    n.length + m.length
  end
end

## assert: test.rb
class C
  def foo: (String, const String) -> Integer
end
