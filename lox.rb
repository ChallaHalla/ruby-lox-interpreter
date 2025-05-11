# typed: strict

require 'sorbet-runtime'
require './scanner'

class Lox
  extend T::Sig

  @had_error = T.let(false, T::Boolean)

  sig { void }
  def main
    if ARGV.length > 1
      puts 'Usage: jlox [script]'
    elsif ARGV.length == 1
      run_file(ARGV[0])
    else
      run_prompt
    end
  end

  sig { params(path: String).void }
  def run_file(path)
    source = File.read(path)
    run(source)
    return unless self.class.had_error

    exit
  end

  sig { params(source: String).void }
  def run(source)
    scanner = Scanner.new(source:)
    tokens = scanner.scan_tokens(source)
    tokens.each do |token|
      puts token
    end
  end

  class << self
    extend T::Sig
    sig { returns(T::Boolean) }
    attr_accessor :had_error

    sig { params(line: Integer, message: String).void }
    def error(line:, message:)
      report(line:, where: '', message:)
    end

    sig { params(line: Integer, where: String, message: String).void }
    def report(line:, where:, message:)
      self.had_error = true
    end
  end

  sig { void }
  def run_prompt
    while true
      print '> '
      input = gets
      break if input.nil?

      run(input)
    end
  end
end

Lox.new.main
