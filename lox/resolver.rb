#typed: true
require_relative "../expr"
require_relative "../stmt"

class Resolver
  include Expr::Visitor

  class FunctionType < T::Enum
    enums do
      FUNCTION = new
      NONE = new
    end
  end

  #: (Interpreter) -> void
  def initialize(interpreter)
    @interpreter = interpreter #: Interpreter
    @scopes = [] #: Array[Hash[String, bool]]
    @current_function = FunctionType::NONE #: FunctionType
  end

  #: (Stmt::Block) -> void
  def visit_block_stmt(stmt)
    begin_scope
    resolve_statements(stmt.statements)
    end_scope
    nil
  end

  #: (Stmt::Expression) -> void
  def visit_expression_stmt(stmt)
    resolve(stmt.expression)
    nil
  end

  #: (Stmt::Function) -> void
  def visit_function_stmt(stmt)
    declare(stmt.name)
    define(stmt.name)
    resolve_function(stmt, FunctionType::FUNCTION)

    nil
  end

  #: (Stmt::If) -> void
  def visit_if_stmt(stmt)
    resolve(stmt.condition)
    resolve(stmt.then_branch)
    resolve(stmt.else_branch) if !stmt.else_branch.nil? 
    nil
  end

  #: (Stmt::Print) -> void
  def visit_print_stmt(stmt)
    resolve(stmt.expression)
    nil
  end

  #: (Stmt::Return) -> void
  def visit_return_stmt(stmt)
    if @current_function == FunctionType::NONE
      Lox.error_for_token(stmt.keyword, "Can't return from top-level code.")
    end

    if !stmt.value.nil?
      resolve(stmt.value)
    end
    nil
  end

  #: (Stmt::Var) -> void
  def visit_var_stmt(stmt)
    declare(stmt.name)
    if !stmt.initializer.nil?
      resolve(stmt.initializer)
    end
    define(stmt.name)
    nil
  end

  #: (Stmt::While) -> void
  def visit_while_stmt(stmt)
    resolve(stmt.condition)
    resolve(stmt.body)
    nil
  end

  #: (Expr::Binary) -> void
  def visit_binary_expr(expr)
    resolve(expr.left)
    resolve(expr.right)
    nil
  end

  #: (Expr::Call) -> void
  def visit_call_expr(expr)
    resolve(expr.callee)
    expr.arguments.each do |argument|
      resolve(argument)
    end
    nil
  end

  #: (Expr::Literal) -> void
  def visit_literal_expr(expr)
    nil
  end

  #: (Expr::Logical) -> void
  def visit_logical_expr(expr)
    resolve(expr.left)
    resolve(expr.right)
    nil
  end

  #: (Expr::Unary) -> void
  def visit_unary_expr(expr)
    resolve(expr.right)
    nil
  end




  #: (Expr::Assign) -> void
  def visit_assign_expr(expr)
    resolve(expr.value)
    resolve_local(expr, expr.name)
    nil
  end

  def visit_variable_expr(expr)
    scope = @scopes.last
    if scope && scope[expr.name] == false
      Lox.error_for_token(expr.name, "Can't read local variable in its own initializer")
    end
    resolve_local(expr, expr.name)
    nil
  end


  def resolve_statements(statements)
    statements.each do |stmt|
      resolve(stmt)
    end
  end


  #: (Expr | Stmt) -> void
  def resolve(statement)
    # Expecting Stmt or Expr
    statement.accept(self)
  end

  private

  #: (Stmt::Function, FunctionType) -> void
  def resolve_function(function, type)
    enclosing_function = @current_function
    @current_function = type

    begin_scope
    function.params.each do |param|
      declare(param)
      define(param)
    end
    resolve_statements(function.body)
    end_scope
    @current_function = enclosing_function
  end

  def begin_scope 
    @scopes << {}
  end

  def end_scope 
    @scopes.pop
  end

  #: (Token) -> void
  def declare(name)
    scope = @scopes.last
    return if scope.nil?

    if scope.has_key?(name.lexeme)
      Lox.error_for_token(name, "Already a variable with this name in this scope.")
    end
    scope[name.lexeme] = false 
  end

  def define(name)
    return if @scopes.size == 0

    scope = @scopes.last
    scope[name.lexeme] = true if scope
  end
  
  #: (Expr, Token) -> void
  def resolve_local(expr, name)
    @scopes.each_with_index do |scope, i| 
      if scope.has_key?(name.lexeme)
        @interpreter.resolve(expr, @scopes.size - 1 - i)
        return
      end
    end
  end
end


