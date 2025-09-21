# typed: true
require_relative './lox_callable'
require_relative './return'
require_relative './environment'

class LoxFunction
  include LoxCallable

  #: (Stmt::Function, Environment, bool) -> void
  def initialize(declaration, closure, is_initializer)
    @declaration = declaration #: Stmt::Function
    @closure = closure #: Environment
    @is_initializer = is_initializer #: bool
  end

  #: (LoxInstance) -> LoxFunction
  def bind(instance)
    environment = Environment.new()
    environment.define("this", instance)
    LoxFunction.new(@declaration, environment, @is_initializer)
  end

  #: (Interpreter, Array[Object]) -> Object
  def call(interpreter, arguments)
    environment = Environment.new(@closure)
    @declaration.params.each_with_index do |param, i|
      environment.define(param.lexeme, arguments[i])
    end

    return_value = catch(:return_value) do
      interpreter.execute_block(@declaration.body, environment)
      nil
    end

    return @closure.get_at(0, "this") if @is_initializer
    return return_value.value if return_value 
  end

  def arity
    @declaration.params.size
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
