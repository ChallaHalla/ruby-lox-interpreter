# typed: strict

require 'sorbet-runtime'
require './scanner'

class Lox
  @had_error = false #: bool

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
    return unless self.class.had_error

    exit
  end

  #: (String) -> void
  def run(source)
    scanner = Scanner.new(source:)
    tokens = scanner.scan_tokens(source)
    tokens.each do |token|
      puts token
    end
  end

  class << self
    extend T::Sig
    #: bool
    attr_accessor :had_error

    #: (line: Integer, message: String) -> void
    def error(line:, message:)
      report(line:, where: '', message:)
    end

    #: (line: Integer, where: String, message: String) -> void
    def report(line:, where:, message:)
      puts "[line #{line}  Error #{where}: #{message}"
      self.had_error = true
    end
  end

  #: () -> void
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
