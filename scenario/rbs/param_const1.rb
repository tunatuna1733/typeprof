## update: test.rbs
class C
  def foo: (const Integer) -> String
end

## update: test.rb
class C
  def foo(n)
    n.to_s
  end
end

## assert: test.rb
class C
  def foo: (const Integer) -> String
end
