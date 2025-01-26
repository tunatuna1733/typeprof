## update: test.rbs
class C
  def foo: (const String) -> Integer
end

## update: test.rb
class C
  def foo(n)
    n.length
  end
end

## assert: test.rb
class C
  def foo: (const String) -> Integer
end
