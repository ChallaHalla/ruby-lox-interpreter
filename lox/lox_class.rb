# typed: true
require_relative './lox_callable'
require_relative './lox_instance'

class LoxClass 
  include LoxCallable
  attr_reader :name
  attr_reader :superclass

  #: (String, LoxClass?, Hash[String, LoxFunction]) -> void
  def initialize(name, superclass, methods)
    @name = name
    @methods = methods #: Hash[String, LoxFunction]
    @superclass = superclass #: LoxClass?
  end

  #: (String) -> LoxFunction?
  def find_method(name)
    return @methods[name] if @methods[name]

    if superclass
      superclass.find_method(name)
    end
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
