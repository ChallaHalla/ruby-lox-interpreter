# typed: strict

require 'sorbet-runtime'

class GenerateAst
  class << self
    #: () -> void
    def run
      raise 'Usage: generate_ast <output directory>' if ARGV.length < 1

      output_dir = ARGV[0]

      define_ast(output_dir:, base_name: 'expr', types:  ['Binary   : Expr left, Token operator, Expr right',
                                                          'Grouping : Expr expression',
                                                          'Literal  : Object value',
                                                          'Unary    : Token operator, Expr right'])
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
      "class MethodNotImplemented < StandardError\n" +
      "end\n"
    end

    #: (String) -> String
    def start_base_class(base_name)
      "class #{base_name.capitalize} \n" +
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
      content = ""
      types.each do |type|
        class_name = type.split(':')[0]&.strip
        fields = type.split(':')[1]&.strip
        snake_case_fields = fields&.split(', ')&.map do |field|
          field.downcase.gsub(' ', '_')
        end
        next unless class_name && fields

        content += build_type_class(base_name:, class_name:, fields: snake_case_fields)
      end
      content
    end

    #: (base_name: String, class_name: String, fields: Array[String]) -> String
    def build_type_class(base_name:, class_name:, fields:)
      content = "class #{class_name} < #{base_name.capitalize} \n"
      content += "include Visitor \n"
      
      fields_list = fields.join(', ')
      fields.each do |field|
        content += "attr_reader :#{field}\n"
      end
      
      content += "def initialize(#{fields_list})\n"
      fields.each do |field|
        content += "@#{field} = #{field}\n"
      end
      content += "end\n"

      content += "def accept(visitor)\n"
      content += "visitor.visit_#{class_name.downcase}_#{base_name}(self)\n"
      content += "end\n"

      content += "end\n"
      content
    end
  end
end

GenerateAst.run
