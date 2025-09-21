# typed: false
# frozen_string_literal: true

class MethodNotImplemented < StandardError
end

class Expr
  def accept(_visitor) = raise(MethodNotImplemented)

  module Visitor
    def visit_assign_expr
      raise MethodNotImplemented
    end

    def visit_binary_expr
      raise MethodNotImplemented
    end

    def visit_call_expr
      raise MethodNotImplemented
    end

    def visit_get_expr
      raise MethodNotImplemented
    end

    def visit_grouping_expr
      raise MethodNotImplemented
    end

    def visit_literal_expr
      raise MethodNotImplemented
    end

    def visit_logical_expr
      raise MethodNotImplemented
    end

    def visit_variable_expr
      raise MethodNotImplemented
    end

    def visit_set_expr
      raise MethodNotImplemented
    end

    def visit_this_expr
      raise MethodNotImplemented
    end

    def visit_unary_expr
      raise MethodNotImplemented
    end
  end

  class Assign < Expr
    include Visitor
    #: Token
    attr_reader :name
    #: Expr
    attr_reader :value

    #: (Token, Expr) -> void
    def initialize(name, value)
      @name = name #: Token
      @value = value #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_assign_expr(self)
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

  class Call < Expr
    include Visitor
    #: Expr
    attr_reader :callee
    #: Token
    attr_reader :paren
    #: Array[Expr]
    attr_reader :arguments

    #: (Expr, Token, Array[Expr]) -> void
    def initialize(callee, paren, arguments)
      @callee = callee #: Expr
      @paren = paren #: Token
      @arguments = arguments #: Array[Expr]
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_call_expr(self)
    end
  end

  class Get < Expr
    include Visitor
    #: Expr
    attr_reader :object
    #: Token
    attr_reader :name

    #: (Expr, Token) -> void
    def initialize(object, name)
      @object = object #: Expr
      @name = name #: Token
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_get_expr(self)
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

  class Logical < Expr
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
      visitor.visit_logical_expr(self)
    end
  end

  class Variable < Expr
    include Visitor
    #: Token
    attr_reader :name

    #: (Token) -> void
    def initialize(name)
      @name = name #: Token
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_variable_expr(self)
    end
  end

  class Set < Expr
    include Visitor
    #: Expr
    attr_reader :object
    #: Token
    attr_reader :name
    #: Expr
    attr_reader :value

    #: (Expr, Token, Expr) -> void
    def initialize(object, name, value)
      @object = object #: Expr
      @name = name #: Token
      @value = value #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_set_expr(self)
    end
  end

  class This < Expr
    include Visitor
    #: Token
    attr_reader :keyword

    #: (Token) -> void
    def initialize(keyword)
      @keyword = keyword #: Token
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_this_expr(self)
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
