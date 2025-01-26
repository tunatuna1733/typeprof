## update: test.rbs
class C
  def foo: (const Integer, const String, Integer) -> String
end

## update: test.rb
class C
  def foo(n, m, k)
    "#{n.to_s}, #{m}, #{k.to_s}"
  end
end

## assert: test.rb
class C
  def foo: (const Integer, const String, Integer) -> String
end
