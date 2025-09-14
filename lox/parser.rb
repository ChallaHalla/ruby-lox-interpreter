# typed: true
# frozen_string_literal: true

class Parser
  class ParseError < StandardError; end

  #: (Array[Token]) -> void
  def initialize(tokens)
    @tokens = tokens
    @current = 0 #: Integer
  end

  #: () -> Array[Stmt]?
  def parse
    # NOTE: Parse errors are not handled right now
    statements = [] #: Array[Stmt]
    until is_at_end?
      result = declaration
      statements << result if result
    end
    statements
  end

  private

  #: () -> Stmt?
  def declaration
    return var_declaration if match(TokenType::VAR)

    statement
  rescue ParseError
    synchronize
    nil
  end

  #: () -> Stmt
  def var_declaration
    name = consume(TokenType::IDENTIFIER, 'Expect variable name.') #: as Token
    initializer = nil
    initializer = expression if match(TokenType::EQUAL)

    consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")
    Stmt::Var.new(name, initializer)
  end

  #: () -> Stmt
  def while_statement
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'while'.")
    condition = expression
    consume(TokenType::RIGHT_PAREN, "Expect ')' after condition.")

    body = statement
    Stmt::While.new(condition, body)
  end

  #: () -> Stmt
  def statement
    return for_statement if match(TokenType::FOR)
    return if_statement if match(TokenType::IF)
    return print_statement if match(TokenType::PRINT)
    return while_statement if match(TokenType::WHILE)

    return Stmt::Block.new(block) if match(TokenType::LEFT_BRACE)

    expression_statement
  end

  #: () -> Stmt
  def for_statement
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'for'.")
    initializer = nil #: Stmt
    if match(TokenType::SEMICOLON)
      initializer = nil 
    elsif match(TokenType::VAR)
      initializer = var_declaration
    else
      initializer = expression_statement
    end

    condition = nil #: Expr
    if !check(TokenType::SEMICOLON)
      condition = expression
    end
    consume(TokenType::SEMICOLON, "Expect ';' after loop condition.")

    increment = nil #: Expr
    if !check(TokenType::RIGHT_PAREN)
      increment = expression
    end
    consume(TokenType::RIGHT_PAREN, "Expect ')' after for clauses.")

    body = statement
    if !increment.nil?
      body = Stmt::Block.new([body, Stmt::Expression.new(increment)])
    end

    condition = Expr::Literal.new(true) if condition.nil?
    body = Stmt::While.new(condition, body)

    if !initializer.nil?
      body = Stmt::Block.new([initializer, body])
    end

    body
  end

  #: () -> Stmt
  def if_statement
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'if'.")
    condition = expression
    consume(TokenType::RIGHT_PAREN, "Expect ')' after 'if condition'.")

    then_branch = statement
    else_branch = nil
    else_branch = statement if match(TokenType::ELSE) 

    Stmt::If.new(condition, then_branch, else_branch)
  end

  #: () -> Stmt
  def print_statement
    value = expression
    consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Stmt::Print.new(value)
  end

  #: () -> Stmt
  def expression_statement
    expr = expression
    consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Stmt::Expression.new(expr)
  end

  #: () -> Array[Stmt]
  def block
    statements = []
    statements << declaration while !check(TokenType::RIGHT_BRACE) && !is_at_end?

    consume(TokenType::RIGHT_BRACE, "Expect '}' after block.")
    statements
  end

  #: () -> Expr
  def expression
    assignment
  end

  #: () -> Expr
  def assignment
    expr = get_or

    if match(TokenType::EQUAL)
      equals = previous
      value = assignment

      if expr.is_a?(Expr::Variable)
        name = expr.name
        return Expr::Assign.new(name, value)
      end
      error(equals, 'Invalid assignment target.')
    end

    expr
  end

  #: () -> Expr
  def get_or
    expr = get_and
    while match(TokenType::OR)
      operator = previous
      right = get_and
      expr = Expr::Logical.new(expr, operator, right)
    end

    expr
  end

  #: () -> Expr
  def get_and
    expr = equality
    while match(TokenType::AND)
      operator = previous
      right = equality
      expr = Expr::Logical.new(expr, operator, right)
    end
    expr
  end

  #: () -> Expr
  def equality
    expr = comparison
    while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  #: () -> Expr
  def comparison
    expr = term
    while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  #: () -> Expr
  def term
    expr = factor
    while match(TokenType::MINUS, TokenType::PLUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  #: () -> Expr
  def factor
    expr = unary
    while match(TokenType::SLASH, TokenType::STAR)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  #: () -> Expr::Literal | Expr::Grouping | Expr::Unary
  def unary
    if match(TokenType::BANG, TokenType::MINUS)
      operator = previous
      right = unary
      Expr::Unary.new(operator, right)
    else
      primary
    end
  end

  #: () -> Expr::Literal | Expr::Grouping
  def primary
    if match(TokenType::TRUE)
      Expr::Literal.new(true)
    elsif match(TokenType::FALSE)
      Expr::Literal.new(false)
    elsif match(TokenType::NIL)
      Expr::Literal.new(nil)
    elsif match(TokenType::STRING, TokenType::NUMBER)
      Expr::Literal.new(previous.literal)
    elsif match(TokenType::LEFT_PAREN)
      expr = expression
      consume(TokenType::RIGHT_PAREN, "Expect ')' after expression")
      Expr::Grouping.new(expr)
    elsif match(TokenType::IDENTIFIER)
      Expr::Variable.new(previous)
    else
      raise error(peek, 'Expected expression.')
    end
  end

  #: (TokenType, String) -> Token?
  def consume(token_type, error_message)
    return advance if check(token_type)

    raise error(peek, error_message)
  end

  def error(token, error_message)
    Lox.error_for_token(token, error_message)
    ParseError.new
  end

  # This method is meant to discard tokens after an
  # error is encountered until the next statement's start
  # is found.
  #: () -> void
  def synchronize
    advance
    until is_at_end?
      return if previous.type == TokenType::SEMICOLON

      case peek.type
      when TokenType::CLASS, TokenType::FUN, TokenType::VAR, TokenType::FOR,
        TokenType::IF, TokenType::WHILE, TokenType::PRINT, TokenType::RETURN
        return
      end

      advance
    end
  end

  #: (*TokenType) -> bool
  def match(*token_types)
    token_types.each do |type|
      if check(type)
        advance
        return true
      end
    end

    false
  end

  #: (TokenType) -> bool
  def check(type)
    return false if is_at_end?

    peek.type == type
  end

  #: () -> Token
  def advance
    @current += 1 unless is_at_end?

    previous
  end

  #: () -> bool
  def is_at_end?
    peek.type == TokenType::EOF
  end

  #: () -> Token
  def peek
    raise 'Invalid token index.' if @current >= @tokens.length

    @tokens[@current]
  end

  #: () -> Token
  def previous
    raise 'Invalid token index.' if @current > @tokens.length
    raise 'Invalid token index.' if @current <= 0

    @tokens[@current - 1]
  end
end
