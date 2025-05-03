# typed: true

require 'sorbet-runtime'

class Lox
  extend T::Sig

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
  end

  sig { params(source: String).void }
  def run(source)
    puts source
  end

  sig { void }
  def run_prompt
  end
end

Lox.new.main
