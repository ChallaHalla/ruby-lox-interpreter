# typed: true

require 'sorbet-runtime'
require_relative '../expr'
require_relative '../token_type'
require_relative '../token'

class AstPrinter
  # (Expr) -> void
  def print(expr)
    expr.accept(self)
  end

  # (Binary) -> void
  def visit_binary_expr(expr)
    parenthesize(expr.token_operator.lexeme, expr.expr_left, expr.expr_right)
  end

  def visit_grouping_expr(expr)
    parenthesize('group', expr.expr_expression)
  end

  def visit_literal_expr(expr)
    return 'nil' if expr.object_value.nil?

    expr.object_value.to_s
  end

  def visit_unary_expr(expr)
    parenthesize(expr.token_operator.lexeme, expr.expr_right)
  end

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
expression = Binary.new(
  Unary.new(
    Token.new(type: TokenType::MINUS, lexeme: '-', literal: nil, line: 1),
    Literal.new(123)
  ),
  Token.new(type: TokenType::STAR, lexeme: '*', literal: nil, line: 1),
  Grouping.new(
    Literal.new(45.67)
  )
)
puts AstPrinter.new.print(expression)
