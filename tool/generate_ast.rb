# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

class GenerateAst
  class << self
    #: () -> void
    def run
      raise 'Usage: generate_ast <output directory>' if ARGV.empty?

      output_dir = ARGV[0]

      define_ast(output_dir:, base_name: 'expr', types:  ['Assign   : Token name, Expr value',
                                                          'Binary   : Expr left, Token operator, Expr right',
                                                          'Grouping : Expr expression',
                                                          'Literal  : Object value',
                                                          'Logical  : Expr left, Token operator, Expr right',
                                                          'Variable : Token name',
                                                          'Unary    : Token operator, Expr right'])

      # TODO: need to extract definting the visitor module from this method so
      # that it isn't defined twice
      define_ast(output_dir:, base_name: 'stmt', types:  ['Block      : Array[Stmt] statements',
                                                          'Expression : Expr expression',
                                                          'If : Expr condition, Stmt then_branch, Stmt else_branch',
                                                          'Print      : Expr expression',
                                                          'Var   : Token name, Expr initializer',
                                                          'While   : Expr condition, Stmt body'])

      exec(" rubocop -A #{output_dir}/expr.rb #{output_dir}/stmt.rb")
    end

    private

    class Attribute
      #: String
      attr_reader :name
      #: String
      attr_reader :type

      #: (String, String) -> void
      def initialize(name, type)
        @name = name
        @type = type
      end
    end

    #: (output_dir: String, base_name: String, types: Array[String]) -> void
    def define_ast(output_dir:, base_name:, types:)
      path = "#{output_dir}/#{base_name}.rb"

      content = build_ast_content(base_name:, types:)
      File.write(path, content)
    end

    #: (base_name: String, types: Array[String]) -> String
    def build_ast_content(base_name:, types:)
      error_class = build_error_class
      # Separating start and end of Expr class so that
      # it can wrap all other expression classes
      base_class_start = start_base_class(base_name)
      visitor_module = build_visitor_module(base_name:, types:)
      type_classes = build_type_classes(base_name:, types:)
      base_class_end = "end \n"
      [error_class, base_class_start, visitor_module, type_classes, base_class_end].join("\n")
    end

    #: () -> String
    def build_error_class
      "class MethodNotImplemented < StandardError\n" \
        "end\n"
    end

    #: (String) -> String
    def start_base_class(base_name)
      "class #{base_name.capitalize} \n" \
        "def accept(visitor); raise MethodNotImplemented;end\n"
    end

    #: (base_name: String, types: Array[String]) -> String
    def build_visitor_module(base_name:, types:)
      content = "module Visitor\n"
      types.each do |type|
        type_name = type.split(':')[0]&.strip&.downcase
        content += "def visit_#{type_name}_#{base_name}\n"
        content += "raise MethodNotImplemented\n "
        content += "end\n"
      end
      content += "end\n"
      content
    end

    #: (base_name: String, types: Array[String]) -> String
    def build_type_classes(base_name:, types:)
      content = ''
      types.each do |type|
        class_name = type.split(':')[0]&.strip
        fields = type.split(':')[1]&.strip

        # Here we want to get the fields and types together
        # to build attr_readers with type info
        next unless class_name && fields

        attributes = fields.split(',').map do |str|
          attr_type, name = str.split(' ')
          next unless attr_type && name

          Attribute.new(name, attr_type)
        end.compact

        content += build_type_class(base_name:, class_name:, attributes:)
      end
      content
    end

    #: (base_name: String, class_name: String, attributes: Array[Attribute]) -> String
    def build_type_class(base_name:, class_name:, attributes:)
      content = "class #{class_name} < #{base_name.capitalize} \n"
      content += "include Visitor \n"

      field_names = []
      sig_types = []

      attributes.each do |attr|
        content += "#: #{attr.type}\n"
        content += "attr_reader :#{attr.name}\n"
        field_names << attr.name
        sig_types << attr.type
      end

      content += "#: (#{sig_types.join(', ')}) -> void\n"
      content += "def initialize(#{field_names.join(', ')})\n"

      attributes.each do |attr|
        content += "@#{attr.name} = #{attr.name} #: #{attr.type}\n"
      end

      content += "end\n"

      content += "#: (Expr) -> void\n"
      content += "def accept(visitor)\n"
      content += "visitor.visit_#{class_name.downcase}_#{base_name}(self)\n"
      content += "end\n"

      content += "end\n"
      content
    end
  end
end

GenerateAst.run
