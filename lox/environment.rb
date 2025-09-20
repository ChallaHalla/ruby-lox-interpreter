# typed: strict
# frozen_string_literal: true

class Environment
  #: Hash[String, Object]
  attr_reader :values

  #: Environment?
  attr_accessor :enclosing

  #: (Environment?) -> void
  def initialize(enclosing = nil)
    @values = {} #: Hash[String, Object]
    @enclosing = enclosing #: Environment?
  end

  #: (String, Object) -> void
  def define(name, value)
    @values[name] = value
  end

  #: (Integer) -> Environment
  def ancestor(distance)
    environment = self #: untyped
    for i in 0...distance
      environment = environment.enclosing
    end
    environment
  end

  #: (Integer, String) -> Object
  def get_at(distance, name)
    ancestor(distance).values[name]
  end

  #: (Integer, Token, Object) -> void
  def assign_at(distance, name, value)
    ancestor(distance).values[name.lexeme] = value
    nil
  end

  #: (Token) -> Object
  def get(name)
    return @values[name.lexeme] if @values.key?(name.lexeme)

    return @enclosing.get(name) unless @enclosing.nil?

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  #: (Token, Object) -> void
  def assign(name, value)
    if @values.key?(name.lexeme)
      @values[name.lexeme] = value
      return
    end

    unless @enclosing.nil?
      @enclosing.assign(name, value)
      return
    end

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end
end
