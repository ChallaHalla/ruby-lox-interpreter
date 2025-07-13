# typed: strict
# frozen_string_literal: true

class RuntimeError < StandardError
  #: Token
  attr_reader :token

  #: (Token, String) -> void
  def initialize(token, message)
    @token = token
    super("#{message}: #{token}")
  end
end
