# typed: strict
class Environment
  #: Hash[String, Object]
  attr_reader :values

  #: () -> void
  def initialize
    @values = {} #: Hash[String, Object]
  end

  #: (String, Object) -> void
  def define(name, value)
    @values[name] = value
  end

  #: (Token) -> Object
  def get(name)
    if @values.has_key?(name.lexeme)
      @values[name.lexeme]
    end

    raise RuntimeError.new(name, "Undefined variable '" + name.lexeme + "'.")
  end
end
