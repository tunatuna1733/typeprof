## update: test.rbs
class C
  def bar: (const String, const String) -> String
end

## update: test.rb
class C
  def foo(n)
    n.length
  end

  def bar(n, m)
    "#{n}, #{foo(m).to_s}"
  end
end

## assert: test.rb
class C
  def foo: (const String) -> Integer
  def bar: (const String, const String) -> String
end
