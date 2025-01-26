## update: test.rbs
class C
  def foo: (Integer, const Integer) -> Integer
end

## update: test.rb
class C
  def foo(n, m)
    n + m
  end
end

## assert: test.rb
class C
  def foo: (Integer, const Integer) -> untyped
end
