# typed: strict
class Environment
  #: Hash[String, Object]
  attr_reader :values

  #: Environment?
  attr_accessor :enclosing

  #: (Environment?) -> void
  def initialize(enclosing=nil)
    @values = {} #: Hash[String, Object]
    @enclosing = enclosing #: Environment?
  end

  #: (String, Object) -> void
  def define(name, value)
    @values[name] = value
  end

  #: (Token) -> Object
  def get(name)
    if @values.has_key?(name.lexeme)
      return @values[name.lexeme]
    end

    if !@enclosing.nil?
      return @enclosing.get(name)
    end

    raise RuntimeError.new(name, "Undefined variable '" + name.lexeme + "'.")
  end

  #: (Token, Object) -> void
  def assign(name, value)
    if @values.has_key?(name.lexeme)
      @values[name.lexeme] = value
      return
    end

    if !@enclosing.nil?
      @enclosing.assign(name, value)
      return 
    end



    raise RuntimeError.new(name, "Undefined variable '" + name.lexeme + "'.")
  end
end
