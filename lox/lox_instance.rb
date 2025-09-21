# typed: true
require_relative 'runtime_error'
class LoxInstance
  #: (LoxClass) -> void
  def initialize(klass)
    @klass = klass
    @fields = {} #: Hash[String, Object]
  end

    #: (Token) -> Object
  def get(name)
    if @fields.has_key?(name.lexeme)
      return @fields[name.lexeme]
    end

    method = @klass.find_method(name.lexeme)
    return method.bind(self) if !method.nil?

    raise RuntimeError.new(name, "Undefined property '#{name.lexeme}'.")
  end

  #: (Token, Object) -> void
  def set(name, value)
    @fields[name.lexeme] = value
  end

  #: () -> String
  def to_string
    binding.irb
    @klass.name + " instance"
  end
end
