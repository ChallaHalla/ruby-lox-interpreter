class Expr
end

class Binary < Expr
  def initialize(expr_left, token_operator, expr_right)
    this.expr_left = expr_left
    this.token_operator = token_operator
    this.expr_right = expr_right
  end
  attr_reader :expr_left, :token_operator, :expr_right
end

class Grouping < Expr
  def initialize(expr_expression)
    this.expr_expression = expr_expression
  end
  attr_reader :expr_expression
end

class Literal < Expr
  def initialize(object_value)
    this.object_value = object_value
  end
  attr_reader :object_value
end

class Unary < Expr
  def initialize(token_operator, expr_right)
    this.token_operator = token_operator
    this.expr_right = expr_right
  end
  attr_reader :token_operator, :expr_right
end
