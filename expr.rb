# typed: false
# frozen_string_literal: true

class MethodNotImplemented < StandardError
end

class Expr
  def accept(_visitor) = raise(MethodNotImplemented)

  module Visitor
    def visit_binary_expr
      raise MethodNotImplemented
    end

    def visit_grouping_expr
      raise MethodNotImplemented
    end

    def visit_literal_expr
      raise MethodNotImplemented
    end

    def visit_unary_expr
      raise MethodNotImplemented
    end
  end

  class Binary < Expr
    include Visitor
    #: Expr
    attr_reader :left
    #: Token
    attr_reader :operator
    #: Expr
    attr_reader :right

    #: (Expr, Token, Expr) -> void
    def initialize(left, operator, right)
      @left = left #: Expr
      @operator = operator #: Token
      @right = right #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_binary_expr(self)
    end
  end

  class Grouping < Expr
    include Visitor
    #: Expr
    attr_reader :expression

    #: (Expr) -> void
    def initialize(expression)
      @expression = expression #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_grouping_expr(self)
    end
  end

  class Literal < Expr
    include Visitor
    #: Object
    attr_reader :value

    #: (Object) -> void
    def initialize(value)
      @value = value #: Object
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_literal_expr(self)
    end
  end

  class Unary < Expr
    include Visitor
    #: Token
    attr_reader :operator
    #: Expr
    attr_reader :right

    #: (Token, Expr) -> void
    def initialize(operator, right)
      @operator = operator #: Token
      @right = right #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_unary_expr(self)
    end
  end
end
