# typed: strict

class Token
  extend T::Sig

  sig { params(type: TokenType, lexeme: String, literal: Object, line: Integer).void }
  def initialize(type:, lexeme:, literal:, line:)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  sig { returns(String) }
  def to_s
    "#{@type} #{@lexeme} #{@literal}"
  end
end
