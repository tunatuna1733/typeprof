## update: test.rbs
class C
  def bar: (const String, const Integer) -> String
end

## update: test.rb
class C
  def foo(n)
    n.to_s
  end

  def bar(n, m)
    "#{n}, #{foo(m)}"
  end
end

## assert: test.rb
class C
  def foo: (const Integer) -> String
  def bar: (const String, const Integer) -> String
end
