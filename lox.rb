# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require './scanner'
require_relative 'lox/ast_printer'
require_relative 'lox/parser'
require_relative 'lox/runtime_error'
require_relative 'lox/interpreter'
require_relative 'lox/resolver'

class Lox
  @had_error = false #: bool
  @had_runtime_error = false #: bool
  @running_prompt = false #: bool
  @interpreter = Interpreter.new #: Interpreter

  #: () -> void
  def main
    if ARGV.length > 1
      puts 'Usage: jlox [script]'
    elsif ARGV.length == 1
      run_file(ARGV[0])
    else
      run_prompt
    end
  end

  #: (String) -> void
  def run_file(path)
    source = File.read(path)
    run(source)
    if self.class.had_error
      exit(65)
    elsif self.class.had_runtime_error
      exit(70)
    end
  end

  #: (String) -> void
  def run(source)
    scanner = Scanner.new(source:)
    tokens = scanner.scan_tokens(source)
    parser = Parser.new(tokens)

    statements = parser.parse

    if self.class.had_error || statements.nil?
      self.class.had_error = false if self.class.running_prompt
      return
    end

    resolver = Resolver.new(self.class.interpreter)
    resolver.resolve_statements(statements)

    if self.class.had_error 
      return
    end

    self.class.interpreter.interpret(statements)
  end

  class << self
    extend T::Sig
    #: bool
    attr_accessor :had_error
    #: bool
    attr_accessor :had_runtime_error
    #: bool
    attr_accessor :running_prompt
    #: Interpreter
    attr_accessor :interpreter

    #: (line: Integer, message: String) -> void
    def error(line:, message:)
      report(line:, where: '', message:)
    end

    #: (Token, String) -> void
    def error_for_token(token, message)
      if token.type == TokenType::EOF
        report(line: token.line, where: ' at end', message: message)
      else
        report(line: token.line, where: " at '#{token.lexeme}'", message: message)
      end
    end

    #: (RuntimeError) -> void
    def runtime_error(err)
      puts "#{err.message} \n [line #{err.token.line}]"
      self.had_runtime_error = true
    end

    #: (line: Integer, where: String, message: String) -> void
    def report(line:, where:, message:)
      puts "[line #{line}  Error #{where}: #{message}"
      self.had_error = true
    end
  end

  #: () -> void
  def run_prompt
    self.class.running_prompt = true #: bool
    loop do
      print '> '
      input = gets
      break if input.nil?

      run(input)
    end
  end
end

Lox.new.main
