class MethodNotImplemented < StandardError
end

class Expr 
def accept(visitor); raise MethodNotImplemented;end
end

module Visitor
def visit_binary_expr
raise MethodNotImplemented
 end
def visit_grouping_expr
raise MethodNotImplemented
 end
def visit_literal_expr
raise MethodNotImplemented
 end
def visit_unary_expr
raise MethodNotImplemented
 end
end

class Binary < Expr 
include Visitor 
attr_reader :expr_left
attr_reader :token_operator
attr_reader :expr_right
def initialize(expr_left, token_operator, expr_right)
@expr_left = expr_left
@token_operator = token_operator
@expr_right = expr_right
end
def accept(visitor)
visitor.visit_binary_expr(self)
end
end
class Grouping < Expr 
include Visitor 
attr_reader :expr_expression
def initialize(expr_expression)
@expr_expression = expr_expression
end
def accept(visitor)
visitor.visit_grouping_expr(self)
end
end
class Literal < Expr 
include Visitor 
attr_reader :object_value
def initialize(object_value)
@object_value = object_value
end
def accept(visitor)
visitor.visit_literal_expr(self)
end
end
class Unary < Expr 
include Visitor 
attr_reader :token_operator
attr_reader :expr_right
def initialize(token_operator, expr_right)
@token_operator = token_operator
@expr_right = expr_right
end
def accept(visitor)
visitor.visit_unary_expr(self)
end
end
