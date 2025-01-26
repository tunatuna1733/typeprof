## update: test.rbs
class C
  def foo: (Integer, const Integer) -> String
end

## update: test.rb
class C
  def foo(n, m)
    "#{n.to_s}, #{m.to_s}"
  end
end

## assert: test.rb
class C
  def foo: (Integer, const Integer) -> String
end
