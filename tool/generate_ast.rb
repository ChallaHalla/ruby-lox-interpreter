# typed: true

require 'sorbet-runtime'

class GenerateAst
  class << self
    # () -> void
    def run
      raise 'Usage: generate_ast <output directory>' if ARGV.length < 1

      output_dir = ARGV[0]

      define_ast(output_dir:, base_name: 'expr', types:  ['Binary   : Expr left, Token operator, Expr right',
                                                          'Grouping : Expr expression',
                                                          'Literal  : Object value',
                                                          'Unary    : Token operator, Expr right'])
    end

    # (
    # |   String output_dir,
    # |   String base_name,
    # |   Array[String] types
    # | ) -> void
    def define_ast(output_dir:, base_name:, types:)
      path = "#{output_dir}/#{base_name}.rb"
      File.write(path, "class #{base_name.capitalize} \n")
      File.write(path, "def accept(visitor); raise 'not implemented';end\n", mode: 'a+')
      File.write(path, "end\n", mode: 'a+')

      define_visitor_module(path:, base_name:, types:)

      types.each do |type|
        class_name = type.split(':')[0]&.strip
        fields = type.split(':')[1]&.strip
        snake_case_fields = fields&.split(', ')&.map do |field|
          field.downcase.gsub(' ', '_')
        end
        next unless class_name && fields

        define_type(path:, base_name:, class_name:, fields: snake_case_fields)
      end
    end

    # : (
    # |  String path,
    # |  String base_name,
    # |  Array[String] types
    # | ) -> Float
    def define_visitor_module(path:, base_name:, types:)
      File.write(path, "module Visitor\n", mode: 'a+')
      types.each do |type|
        type_name = type.split(':')[0]&.strip&.downcase
        File.write(path, "def visit_#{type_name}_#{base_name}\n", mode: 'a+')
        File.write(path, "raise 'not_implemented'\n ", mode: 'a+')
        File.write(path, "end\n", mode: 'a+')
      end
      File.write(path, "end\n", mode: 'a+')
    end

    # (
    # |   String path,
    # |   String base_name,
    # |   String class_name,
    # |   Array[String] fields
    # | ) -> void
    def define_type(path:, base_name:, class_name:, fields:)
      File.write(path, "class #{class_name} < #{base_name.capitalize} \n", mode: 'a+')

      File.write(path, "include Visitor \n", mode: 'a+')
      fields_list = fields.join(', ')
      fields.each do |field|
        File.write(path, "attr_reader :#{field}\n", mode: 'a+')
      end
      File.write(path, "def initialize(#{fields_list})\n", mode: 'a+')
      fields.each do |field|
        File.write(path, "@#{field} = #{field}\n", mode: 'a+')
      end
      File.write(path, "end\n", mode: 'a+')

      # define visitor method
      File.write(path, "def accept(visitor)\n", mode: 'a+')
      File.write(path, "visitor.visit_#{class_name.downcase}_#{base_name}(self)\n", mode: 'a+')
      File.write(path, "end\n", mode: 'a+')

      File.write(path, "end\n", mode: 'a+')
    end
  end
end

# Make module with methods that eaise if not implemented
# Add methods on child classes to implement visitations
GenerateAst.run
