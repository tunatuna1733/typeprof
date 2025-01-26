## update: test.rbs
class C
  def bar: (const String) -> Integer
end

## update: test.rb
class C
  def foo(n)
    n.length
  end

  def bar(n)
    foo(n)
  end
end

## assert: test.rb
class C
  def foo: (const String) -> Integer
  def bar: (const String) -> Integer
end
