# typed: strict

class Token
  extend T::Sig

  #: String
  attr_reader :lexeme
  #: TokenType
  attr_reader :type

  #: Object
  attr_reader :literal

  #: Integer
  attr_reader :line

  #: (type: TokenType, lexeme: String, literal: Object, line: Integer) -> void
  def initialize(type:, lexeme:, literal:, line:)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  #: () -> String
  def to_s
    "#{@type} #{@lexeme} #{@literal}"
  end
end
