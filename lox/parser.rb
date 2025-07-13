# frozen_string_literal: true
# typed: true

require_relative '../token_type'

class Parser
  class ParseError < StandardError; end

  # : (Array[Token]) -> void
  def initialize(tokens)
    @tokens = tokens
    @current = 0 # : Integer
  end

  #: () -> Expr?
  def parse
    begin
      return expression
    rescue ParseError 
      return
    end
  end

  private

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
    else
      raise error(peek(), "Expected expression.")
    end
  end

  #: (TokenType, String) -> void
  def consume(token_type, error_message)
    return advance unless check(token_type)

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
