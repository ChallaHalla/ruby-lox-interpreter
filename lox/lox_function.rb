require_relative './lox_callable'
require_relative './return'
require_relative './environment'

class LoxFunction
  include LoxCallable

  #: (Stmt::Function, Environment) -> LoxFunction
  def initialize(declaration, closure)
    @declaration = declaration #: Stmt::Function
    @closure = closure #: Environment
  end
  

  #: (Interpreter, Array[Object]) -> Object
  def call(interpreter, arguments)
    environment = Environment.new(@closure)
    @declaration.params.each_with_index do |param, i|
      environment.define(param.lexeme, arguments[i])
    end

    return_value = catch(:return_value) do
      interpreter.execute_block(@declaration.body, environment)
    end

    return return_value.value
  end

  def arity
    @declaration.params.size
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
