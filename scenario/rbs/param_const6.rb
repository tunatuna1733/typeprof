## update: test.rbs
class C
  def foo: (String, const Integer) -> String
end

## update: test.rb
class C
  def foo(n, m)
    "#{n}, #{m.to_s}"
  end
end

## assert: test.rb
class C
  def foo: (String, const Integer) -> String
end
