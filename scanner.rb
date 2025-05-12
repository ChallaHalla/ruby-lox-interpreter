# typed: strict

require './token'
require './token_type'

class Scanner
  extend T::Sig

  sig { returns(String) }
  attr_accessor :source

  sig { returns(T::Array[Token]) }
  attr_accessor :tokens

  sig { returns(Integer) }
  attr_accessor :start, :current, :line

  @keywords = T.let({
    'and' => TokenType::AND,
    'class' => TokenType::CLASS,
    'else' => TokenType::ELSE,
    'false' => TokenType::FALSE,
    'for' => TokenType::FOR,
    'fun' => TokenType::FUN,
    'if' => TokenType::IF,
    'nil' => TokenType::NIL,
    'or' => TokenType::OR,
    'print' => TokenType::PRINT,
    'return' => TokenType::RETURN,
    'super' => TokenType::SUPER,
    'this' => TokenType::THIS,
    'true' => TokenType::TRUE,
    'var' => TokenType::VAR,
    'while' => TokenType::WHILE
  }, T::Hash[String, TokenType])

  class << self
    extend T::Sig
    sig { returns(T::Hash[String, TokenType]) }
    attr_reader :keywords
  end

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
      @start = @current
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
    return unless c

    @current += 1

    case c
    when '('
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
    when '/'
      if match('/')
        advance while peek != "\n" && !is_at_end?
      else
        add_token_from_type(TokenType::SLASH)
      end
    when ' ', "\r", "\t"
      nil
    when "\n"
      @line += 1
    when '"'
      string
    else
      if is_digit?(c)
        number
      elsif is_alpha?(c)
        identifier
      else
        Lox.error(line: @line, message: 'Unexpected character.')
      end
    end
  end

  sig { params(expected: String).returns(T::Boolean) }
  def match(expected)
    return false if is_at_end?
    return false if @source[@current] != expected

    @current += 1
    true
  end

  sig { void }
  def string
    while !is_at_end? && peek != '"'
      @line += 1 if peek == "\n"
      advance
    end

    Lox.error(line: @line, message: 'Unterminated String.') if is_at_end?
    advance
    string_value = @source[start + 1, current - 2]
    add_token(type: TokenType::STRING, literal: string_value)
  end

  sig { void }
  def number
    advance while is_digit?(peek)
    if peek == '.' && is_digit?(peek_next)
      advance
      advance while is_digit?(peek)
    end

    str_number = @source[@start..@current]
    # NOTE: Parsing here is done in a dangerous way. Strings that
    # are not numbers will be parsed to 0.0. Need to find a
    # parsing strategy which will throw an error for strings
    parsed = str_number.to_f
    add_token(type: TokenType::NUMBER, literal: parsed)
  end

  sig { void }
  def identifier
    advance while is_alpha_numeric?(peek)
    text = @source[@start..@current]
    raise 'text not found' if text.nil?

    type = self.class.keywords[text] || TokenType::IDENTIFIER

    add_token_from_type(type)
  end

  sig { params(char: String).returns(T::Boolean) }
  def is_digit?(char)
    char.ord >= '0'.ord && char.ord <= '9'.ord
  end

  sig { params(char: String).returns(T::Boolean) }
  def is_alpha?(char)
    char.ord >= 'a'.ord && char.ord <= 'z'.ord ||
      char.ord >= 'A'.ord && char.ord <= 'Z'.ord ||
      char == '_'
  end

  sig { params(char: String).returns(T::Boolean) }
  def is_alpha_numeric?(char)
    is_digit?(char) || is_alpha?(char)
  end

  sig { params(type: TokenType).void }
  def add_token_from_type(type)
    add_token(type: type, literal: nil)
  end

  sig { params(type: TokenType, literal: Object).void }
  def add_token(type:, literal:)
    text = @source[@start..@current - 1]
    raise 'substring not found' if text.nil?

    @tokens << Token.new(
      type: type,
      lexeme: text,
      literal:,
      line: line
    )
  end

  sig { returns(T.nilable(String)) }
  def advance
    c = @source[@current]

    @current += 1
    c
  end

  sig { returns(String) }
  def peek
    return '\0' if is_at_end?

    current_char = @source[@current]
    raise 'invalid character position value' if current_char.nil?

    current_char
  end

  sig { returns(String) }
  def peek_next
    return '\0' if current + 1 == @source.length

    next_char = @source[@current + 1]
    raise 'invalid character position value' if next_char.nil?

    next_char
  end

  sig { returns(T::Boolean) }
  def is_at_end?
    @current >= @source.length
  end
end
