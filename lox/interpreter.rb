# typed: strict
require_relative "../expr"
require_relative "../stmt"
require_relative "./environment"

require_relative "runtime_error"
class Interpreter
  include Expr::Visitor
  include Stmt::Visitor
  #: Environment
  attr_reader :environment

  #: () -> void
  def initialize
    @environment = Environment.new() #: Environment
  end

  #: (Array[Stmt]) -> void
  def interpret(statements)
    begin
      statements.each do |stmt|
        execute(stmt)
      end
    rescue RuntimeError => e
      Lox.runtime_error(e)
    end
  end

  #: (Expr::Literal) -> Object
  def visit_literal_expr(expr)
    return expr.value
  end

  #: (Expr::Grouping) -> Object
  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  #: (Expr::Unary) -> Object
  def visit_unary_expr(expr)
    right = evaluate(expr.right)
    case expr.operator.type
    when TokenType::MINUS
      # evaluate should eventually return a literal
      # which will map to a Ruby type from visit_literal_expr
      check_number_operand(expr.operator, right)
      right = right #: as Numeric
      -1 * right 
    when TokenType::BANG
      return !is_truthy?(right)
    end
  end

  #: (Expr::Variable) -> Object
  def visit_variable_expr(expr)
    environment.get(expr.name)
  end

  #: (Expr::Binary) -> Object
  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when TokenType::STAR
      check_number_operands(expr.operator, left, right)
      left = left #: as Numeric
      right = right #: as Numeric
      left * right
    when TokenType::SLASH
      check_number_operands(expr.operator, left, right)
      left = left #: as Numeric
      right = right #: as Numeric
      left / right.to_f
    when TokenType::PLUS
      if left.is_a?(Numeric) && right.is_a?(Numeric)
        left + right
      elsif left.is_a?(String) && right.is_a?(String)
        left + right
      else
        raise RuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
      end
    when TokenType::MINUS
      check_number_operands(expr.operator, left, right)
      left = left #: as Numeric
      right = right #: as Numeric
      left - right
    when TokenType::GREATER
      check_number_operands(expr.operator, left, right)
      left = left #: as Numeric
      right = right #: as Numeric
      left > right
    when TokenType::GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      left = left #: as Numeric
      right = right #: as Numeric
      left >= right
    when TokenType::LESS
      check_number_operands(expr.operator, left, right)
      left = left #: as Numeric
      right = right #: as Numeric
      left < right
    when TokenType::LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      left = left #: as Numeric
      right = right #: as Numeric
      left <= right
    when TokenType::BANG_EQUAL
      # This is slightly different from the book because 
      # comparisons on NilClass are easier in Ruby
      left != right
    when TokenType::EQUAL_EQUAL
      left == right
    end
  end

  #: (Stmt::Print) -> void
  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
  end

  #: (Stmt::Var) -> void
  def visit_var_stmt(stmt)
    value = nil
    if !stmt.initializer.nil?
      value = evaluate(stmt.initializer)
    end

    self.environment.define(stmt.name.lexeme, value)
    nil
  end

#: (Stmt::Expression) -> void
  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
  end



  private

  #: (Stmt) -> void
  def execute(stmt)
    stmt.accept(self)
  end

  #: (Object) -> String
  def stringify(value)
    case value
    when NilClass
      "nil"
    when Numeric
      str_value = value.to_s
      if str_value.end_with?(".0")
        return str_value[0, str_value.length-2] #: as String
      else
        str_value
      end
    else
      value.to_s
    end
  end

  #: (Token, Object) -> void
  def check_number_operand(operator, operand)
    return if operand.is_a?(Numeric)
    raise RuntimeError.new(operator, "Operand must be a number.")
  end

  #: (Token, Object, Object) -> void
  def check_number_operands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)
    raise RuntimeError.new(operator, "Operand must be a number.")
  end
  
  #: (Object) -> bool
  def is_truthy?(value)
    case value
    when NilClass
      false
    when TrueClass, FalseClass
      value 
    else
      true
    end
  end

  #: (Expr) -> Object
  def evaluate(expr)
    expr.accept(self)
  end

end
