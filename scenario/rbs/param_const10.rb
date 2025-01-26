## update: test.rbs
class C
  def foo: (const Integer, String, const String) -> String
end

## update: test.rb
class C
  def foo(n, m, k)
    "#{n.to_s}, #{m}, #{k}"
  end
end

## assert: test.rb
class C
  def foo: (const Integer, String, const String) -> String
end
