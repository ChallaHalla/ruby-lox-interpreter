class MethodNotImplemented < StandardError
end
module LoxCallable

  #: () -> Integer
  def arity
  end
  #: (Interpreter, Array[Object]) -> Object
  def call(interpreter, arguments)
    raise MethodNotImplemented
  end

end
