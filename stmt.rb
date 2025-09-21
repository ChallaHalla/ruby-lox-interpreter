# typed: false
# frozen_string_literal: true

class MethodNotImplemented < StandardError
end

class Stmt
  def accept(_visitor) = raise(MethodNotImplemented)

  module Visitor
    def visit_block_stmt
      raise MethodNotImplemented
    end

    def visit_class_stmt
      raise MethodNotImplemented
    end

    def visit_expression_stmt
      raise MethodNotImplemented
    end

    def visit_function_stmt
      raise MethodNotImplemented
    end

    def visit_if_stmt
      raise MethodNotImplemented
    end

    def visit_print_stmt
      raise MethodNotImplemented
    end

    def visit_return_stmt
      raise MethodNotImplemented
    end

    def visit_var_stmt
      raise MethodNotImplemented
    end

    def visit_while_stmt
      raise MethodNotImplemented
    end
  end

  class Block < Stmt
    include Visitor
    #: Array[Stmt]
    attr_reader :statements

    #: (Array[Stmt]) -> void
    def initialize(statements)
      @statements = statements #: Array[Stmt]
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_block_stmt(self)
    end
  end

  class Class < Stmt
    include Visitor
    #: Token
    attr_reader :name
    #: Array[Stmt::Function]
    attr_reader :methods

    #: (Token, Array[Stmt::Function]) -> void
    def initialize(name, methods)
      @name = name #: Token
      @methods = methods #: Array[Stmt::Function]
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_class_stmt(self)
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

  class Function < Stmt
    include Visitor
    #: Token
    attr_reader :name
    #: Array[Token]
    attr_reader :params
    #: Array[Stmt]
    attr_reader :body

    #: (Token, Array[Token], Array[Stmt]) -> void
    def initialize(name, params, body)
      @name = name #: Token
      @params = params #: Array[Token]
      @body = body #: Array[Stmt]
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_function_stmt(self)
    end
  end

  class If < Stmt
    include Visitor
    #: Expr
    attr_reader :condition
    #: Stmt
    attr_reader :then_branch
    #: Stmt
    attr_reader :else_branch

    #: (Expr, Stmt, Stmt) -> void
    def initialize(condition, then_branch, else_branch)
      @condition = condition #: Expr
      @then_branch = then_branch #: Stmt
      @else_branch = else_branch #: Stmt
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_if_stmt(self)
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

  class Return < Stmt
    include Visitor
    #: Token
    attr_reader :keyword
    #: Expr
    attr_reader :value

    #: (Token, Expr) -> void
    def initialize(keyword, value)
      @keyword = keyword #: Token
      @value = value #: Expr
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_return_stmt(self)
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

  class While < Stmt
    include Visitor
    #: Expr
    attr_reader :condition
    #: Stmt
    attr_reader :body

    #: (Expr, Stmt) -> void
    def initialize(condition, body)
      @condition = condition #: Expr
      @body = body #: Stmt
    end

    #: (Expr) -> void
    def accept(visitor)
      visitor.visit_while_stmt(self)
    end
  end
end
