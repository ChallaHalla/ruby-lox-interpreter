# typed: strict

class Scanner
  extend T::Sig

  sig { returns(String) }
  attr_accessor :source

  sig { returns(T::Array[Token]) }
  attr_accessor :tokens

  sig { returns(Integer) }
  attr_accessor :start, :current, :line

  sig { params(source: String).void }
  def initialize(source:)
    @source = T.let(source, String)
    @tokens = T.let([], T::Array[Token])
    @start = T.let(0, Integer)
    @current = T.let(0, Integer)
    @line = T.let(1, Integer)
  end

  sig { params(source: String).returns(T::Array[Token]) }
  def scan_tokens(source)
    until is_at_end?
      start = current
      scan_token
    end

    @tokens << Token.new(
      type: TokenType::EOF,
      lexeme: '',
      literal: nil,
      line: line
    )
  end

  private

  sig { void }
  def scan_token
    c = @source[@current]
    @current += 1

    case c
    when '(TokenType::'
      add_token_from_type(TokenType::LEFT_PAREN)
    when ')'
      add_token_from_type(TokenType::RIGHT_PAREN)
    when '{'
      add_token_from_type(TokenType::LEFT_BRACE)
    when '}'
      add_token_from_type(TokenType::RIGHT_BRACE)
    when ','
      add_token_from_type(TokenType::COMMA)
    when '.'
      add_token_from_type(TokenType::DOT)
    when '-'
      add_token_from_type(TokenType::MINUS)
    when '+'
      add_token_from_type(TokenType::PLUS)
    when ';'
      add_token_from_type(TokenType::SEMICOLON)
    when '*'
      add_token_from_type(TokenType::STAR)
    when '!'
      token = match('=') ? TokenType::BANG_EQUAL : TokenType::BANG
      add_token_from_type(token)
    when '='
      token = match('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL
      add_token_from_type(token)
    when '<'
      token = match('=') ? TokenType::LESS_EQUAL : TokenType::LESS
      add_token_from_type(token)
    when '>'
      token = match('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER
      add_token_from_type(token)
    else
      Lox.error(line: @line, message: 'Unexpected character.')
    end
  end

  sig { params(expected: String).returns(T::Boolean) }
  def match(expected)
    return false if is_at_end?
    return false if @source[current] != expected

    @current += 1
    true
  end

  sig { params(type: TokenType).void }
  def add_token_from_type(type)
    add_token(type: type, literal: nil)
  end

  sig { params(type: TokenType, literal: Object).void }
  def add_token(type:, literal:)
    text = @source[start, current]
    raise 'substring not found' if text.nil?

    @tokens << Token.new(
      type: type,
      lexeme: text,
      literal:,
      line: line
    )
  end

  sig { returns(String) }
  def advance
    c = @source[@current]
    raise 'substring not found' if c.nil?

    @current += 1
    c
  end

  sig { returns(T::Boolean) }
  def is_at_end?
    current >= @source.length
  end
end
