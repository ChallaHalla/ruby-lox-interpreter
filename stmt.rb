# typed: false
# frozen_string_literal: true

class MethodNotImplemented < StandardError
end

class Stmt
  def accept(_visitor) = raise(MethodNotImplemented)

  module Visitor
    def visit_expression_stmt
      raise MethodNotImplemented
    end

    def visit_print_stmt
      raise MethodNotImplemented
    end

    def visit_var_stmt
      raise MethodNotImplemented
    end
  end

  class Expression < Stmt
    include Visitor
    #: Expr
    attr_reader :expression

    #: (Expr) -> void
    def initialize(expression)
      @expression = expression #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_expression_stmt(self)
    end
  end

  class Print < Stmt
    include Visitor
    #: Expr
    attr_reader :expression

    #: (Expr) -> void
    def initialize(expression)
      @expression = expression #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_print_stmt(self)
    end
  end

  class Var < Stmt
    include Visitor
    #: Token
    attr_reader :name
    #: Expr
    attr_reader :initializer

    #: (Token, Expr) -> void
    def initialize(name, initializer)
      @name = name #: Token
      @initializer = initializer #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_var_stmt(self)
    end
  end
end
