# typed: strict
# frozen_string_literal: true

require_relative '../expr'
require_relative '../stmt'
require_relative './environment'
require_relative './lox_callable'
require_relative './lox_function'

require_relative 'runtime_error'
class Interpreter
  include Expr::Visitor
  include Stmt::Visitor
  #: Environment
  attr_reader :globals

  #: () -> void
  def initialize
    @globals = Environment.new #: Environment
    @environment = globals #: Environment
    globals.define("clock", Class.new do 
      include LoxCallable

      #: () -> Integer
      def arity
        return 0
      end

      #: (Interpreter, Array[Object]) -> Object
      def call(interpreter, arguments)
        (Time.now.to_f * 1000).to_i
      end
      
      #: () -> String
      def to_s
        "<native fn>"
      end
    end
    )
  end

  #: (Array[Stmt]) -> void
  def interpret(statements)
    statements.each do |stmt|
      execute(stmt)
    end
  rescue RuntimeError => e
    Lox.runtime_error(e)
  end

  #: (Expr::Literal) -> Object
  def visit_literal_expr(expr)
    expr.value
  end

  #: (Expr::Logical) -> Object
  def visit_logical_expr(expr)
    left = evaluate(expr.left)
    if expr.operator.type == TokenType::OR
      # left being true for an OR means we can short circuit
      return left if is_truthy?(left) 
    else
      # right being false for an AND means we can short circuit
      return left if !is_truthy?(left) 
    end

    # If neither checked cases can short circuit, we must evaluate the RHS
    return evaluate(expr.right)
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
      # w{hich will map to a Ruby type from visit_literal_expr
      check_number_operand(expr.operator, right)
      right = right #: as Numeric
      -1 * right
    when TokenType::BANG
      !is_truthy?(right)
    end
  end

  #: (Expr::Variable) -> Object
  def visit_variable_expr(expr)
    @environment.get(expr.name)
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
        raise RuntimeError.new(expr.operator, 'Operands must be two numbers or two strings.')
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

  #: (Expr::Call) -> Object
  def visit_call_expr(expr)
    callee = evaluate(expr.callee)
    arguments = []
    expr.arguments.each do |arg|
      arguments << evaluate(arg)
    end

    if !callee.is_a?(LoxCallable)
      raise RuntimeError.new(expr.paren, 'Can only call functions and classes.')
    end
    function = callee

    if arguments.size != function.arity
      raise RuntimeError.new(expr.paren, "Expected #{function.arity} arguments but got #{arguments.size}.")
    end
    function.call(self, arguments)
  end

  #: (Stmt::Print) -> void
  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
  end

  #: (Stmt::Var) -> void
  def visit_var_stmt(stmt)
    value = nil
    value = evaluate(stmt.initializer) unless stmt.initializer.nil?

    @environment.define(stmt.name.lexeme, value)
    nil
  end

  #: (Stmt::While) -> void
  def visit_while_stmt(stmt)
    while is_truthy?(evaluate(stmt.condition))
      execute(stmt.body)
    end
    nil
  end

  #: (Expr::Assign) -> Object
  def visit_assign_expr(expr)
    value = evaluate(expr.value)
    @environment.assign(expr.name, value)
    value
  end

  #: (Stmt::Expression) -> void
  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
  end

  def visit_function_stmt(stmt)
    function = LoxFunction.new(stmt)
    @environment.define(stmt.name.lexeme, function)

    nil
  end

  #: (Stmt::If) -> void
  def visit_if_stmt(stmt)
    if is_truthy?(evaluate(stmt.condition))
      execute(stmt.then_branch)
    elsif !stmt.else_branch.nil?
      execute(stmt.else_branch)
    end
    nil
  end

  #: (Stmt::Block) -> void
  def visit_block_stmt(stmt)
    execute_block(stmt.statements, Environment.new(@environment))
    nil
  end

  def execute_block(statements, environment)
    previous = @environment
    begin
      @environment = environment
      statements.each do |statement|
        execute(statement)
      end
    ensure
      @environment = previous
    end
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
      'nil'
    when Numeric
      str_value = value.to_s
      if str_value.end_with?('.0')
        str_value[0, str_value.length - 2] #: as String
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

    raise RuntimeError.new(operator, 'Operand must be a number.')
  end

  #: (Token, Object, Object) -> void
  def check_number_operands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)

    raise RuntimeError.new(operator, 'Operand must be a number.')
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
