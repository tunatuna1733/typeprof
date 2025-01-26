## update: test.rbs
class C
  def foo: (const Integer) -> String
end

## update: test.rb
class C
  def foo(n)
    n.to_s
  end

  def bar(n)
    foo(n)
  end
end

## assert: test.rb
class C
  def foo: (const Integer) -> String
  def bar: (untyped) -> String
end
