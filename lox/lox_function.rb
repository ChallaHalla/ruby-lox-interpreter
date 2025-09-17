require_relative './lox_callable'
require_relative './return'

class LoxFunction
  include LoxCallable

  #: (Stmt::Function) -> LoxFunction
  def initialize(declaration)
    @declaration = declaration #: Stmt::Function
  end
  

  #: (Interpreter, Array[Object]) -> Object
  def call(interpreter, arguments)
    environment = Environment.new(interpreter.globals)
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
