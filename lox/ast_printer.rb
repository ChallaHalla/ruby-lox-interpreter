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
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  #: (Expr::Grouping) -> void
  def visit_grouping_expr(expr)
    parenthesize('group', expr.expression)
  end

  #: (Expr::Literal) -> void
  def visit_literal_expr(expr)
    return 'nil' if expr.value.nil?

    expr.value.to_s
  end

  #: (Expr::Unary) -> void
  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
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
