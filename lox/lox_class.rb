# typed: true
require_relative './lox_callable'
require_relative './lox_instance'

class LoxClass 
  include LoxCallable
  attr_reader :name

  #: (String, Hash[String, LoxFunction]) -> void
  def initialize(name, methods)
    @name = name
    @methods = methods #: Hash[String, LoxFunction]
  end

  #: (String) -> LoxFunction?
  def find_method(name)
    return @methods[name] 
  end

  #: () -> String 
  def to_s
    name
  end

  #: (Interpreter, Array[Object]) -> Object
  def call (interpreter, arguments)
    instance = LoxInstance.new(self)
    initializer = find_method("init")
    if !initializer.nil?
      initializer.bind(instance).call(interpreter, arguments)
    end
    instance
  end 

  #: () -> Integer
  def arity 
    initializer = find_method("init")
    return 0 if initializer.nil?
    return initializer.arity
  end
end
