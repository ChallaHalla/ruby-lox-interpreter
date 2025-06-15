class Expr
  def accept(visitor) = raise('not implemented')
end

module Visitor
  def visit_binary_expr
    raise 'not_implemented'
  end

  def visit_grouping_expr
    raise 'not_implemented'
  end

  def visit_literal_expr
    raise 'not_implemented'
  end

  def visit_unary_expr
    raise 'not_implemented'
  end
end

class Binary < Expr
  def initialize(expr_left, token_operator, expr_right)
    this.expr_left = expr_left
    this.token_operator = token_operator
    this.expr_right = expr_right
  end
  attr_reader :expr_left, :token_operator, :expr_right

  def accept(visitor)
    visitor.visit_binary_expr(this)
  end
end

class Grouping < Expr
  def initialize(expr_expression)
    this.expr_expression = expr_expression
  end
  attr_reader :expr_expression

  def accept(visitor)
    visitor.visit_grouping_expr(this)
  end
end

class Literal < Expr
  def initialize(object_value)
    this.object_value = object_value
  end
  attr_reader :object_value

  def accept(visitor)
    visitor.visit_literal_expr(this)
  end
end

class Unary < Expr
  def initialize(token_operator, expr_right)
    this.token_operator = token_operator
    this.expr_right = expr_right
  end
  attr_reader :token_operator, :expr_right

  def accept(visitor)
    visitor.visit_unary_expr(this)
  end
end
