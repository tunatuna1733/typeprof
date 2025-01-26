## update: test.rbs
class C
  def foo: (const Integer, String) -> String
end

## update: test.rb
class C
  def foo(n, m)
    "#{n.to_s}, #{m}"
  end
end

## assert: test.rb
class C
  def foo: (const Integer, String) -> String
end
