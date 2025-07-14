# frozen_string_literal: true
# typed: true

class Parser
  class ParseError < StandardError; end

  # : (Array[Token]) -> void
  def initialize(tokens)
    @tokens = tokens
    @current = 0 # : Integer
  end

  #: () -> Array[Stmt]?
  def parse
    # NOTE: Parse errors are not handled right now
    statements = [] #: Array[Stmt]
    while !is_at_end? do 
      statements << declaration
    end
    return statements
  end

  private

  def declaration
    begin
      return var_declaration if match(TokenType::VAR)
      statement
    rescue ParseError
      synchronize
      nil
    end
  end

  def var_declaration
    name = consume(TokenType::IDENTIFIER, "Expect variable name.") #: as Token
    initializer = nil
    if match(TokenType::EQUAL)
      initializer = expression
    end

    consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")
    Stmt::Var.new(name, initializer)
  end

  #: () -> Stmt
  def statement
    return print_statement if match(TokenType::PRINT)
    expression_statement
  end

  def declaration
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

  # : () -> Expr
  def expression
    equality
  end

  # : () -> Expr
  def equality
    expr = comparison
    while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  # : () -> Expr
  def comparison
    expr = term
    while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  # : () -> Expr
  def term
    expr = factor
    while match(TokenType::MINUS, TokenType::PLUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end
    expr
  end

  # : () -> Expr
  def factor
    expr = unary
    while match(TokenType::SLASH, TokenType::STAR)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  # : () -> Expr::Literal | Expr::Grouping | Expr::Unary
  def unary
    if match(TokenType::BANG, TokenType::MINUS)
      operator = previous
      right = unary
      Expr::Unary.new(operator, right)
    else
      primary
    end
  end

  # : () -> Expr::Literal | Expr::Grouping
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
      raise error(peek(), "Expected expression.")
    end
  end

  #: (TokenType, String) -> Token?
  def consume(token_type, error_message)
    if check(token_type)
      return advance 
    end

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

  # : (*TokenType) -> bool
  def match(*token_types)
    token_types.each do |type|
      if check(type)
        advance
        return true
      end
    end

    false
  end

  # : (TokenType) -> bool
  def check(type)
    return false if is_at_end?

    peek.type == type
  end

  # : () -> Token
  def advance
    @current += 1 unless is_at_end?

    previous
  end

  # : () -> bool
  def is_at_end?
    peek.type == TokenType::EOF
  end

  # : () -> Token
  def peek
    raise 'Invalid token index.' if @current >= @tokens.length

    @tokens[@current]
  end

  # : () -> Token
  def previous
    raise 'Invalid token index.' if @current > @tokens.length
    raise 'Invalid token index.' if @current <= 0

    @tokens[@current - 1]
  end
end
