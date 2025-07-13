# typed: strict

require 'sorbet-runtime'
require_relative '../expr'
require_relative '../token_type'
require_relative '../token'

class AstPrinter
  extend T::Sig

  #: (Expr) -> void
  def print(expr)
    expr.accept(self)
  end

  #: (Expr::Binary) -> void
  def visit_binary_expr(expr)
    parenthesize(expr.token_operator.lexeme, expr.expr_left, expr.expr_right)
  end

  #: (Expr::Grouping) -> void
  def visit_grouping_expr(expr)
    parenthesize('group', expr.expr_expression)
  end

  #: (Expr::Literal) -> void
  def visit_literal_expr(expr)
    return 'nil' if expr.object_value.nil?

    expr.object_value.to_s
  end

  #: (Expr::Unary) -> void
  def visit_unary_expr(expr)
    parenthesize(expr.token_operator.lexeme, expr.expr_right)
  end

  #: (String, *Expr) -> void
  def parenthesize(name, *exprs)
    str = "(#{name}"
    exprs.each do |expr|
      str += ' '
      str += expr.accept(self)
    end
    str += ')'
    str
  end
end
