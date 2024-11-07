## update: test.rbs
class C
  def foo: (const Integer) -> Integer
end

## update: test.rb
class C
  def foo(n)
    bar(n)
  end

  def bar(n)
  end
end

## assert: test.rb
class C
  def foo: (const Integer) -> nil
  def bar: (const Integer) -> nil
end
