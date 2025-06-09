# typed: strict

require 'sorbet-runtime'

class GenerateAst
  class << self
    extend T::Sig
    sig { void }
    def run
      raise 'Usage: generate_ast <output directory>' if ARGV.length < 1

      output_dir = ARGV[0]

      define_ast(output_dir:, base_name: 'expr', types:  ['Binary   : Expr left, Token operator, Expr right',
                                                          'Grouping : Expr expression',
                                                          'Literal  : Object value',
                                                          'Unary    : Token operator, Expr right'])
    end

    sig { params(output_dir: String, base_name: String, types: T::Array[String]).void }
    def define_ast(output_dir:, base_name:, types:)
      path = "#{output_dir}/#{base_name}.rb"
      File.write(path, "class #{base_name.capitalize} \n")
      File.write(path, "end\n", mode: 'a+')

      types.each do |type|
        class_name = type.split(':')[0].strip
        fields = type.split(':')[1].strip
        snake_case_fields = fields.split(', ').map do |field|
          field.downcase.gsub(' ', '_')
        end
        define_type(path:, base_name:, class_name:, fields: snake_case_fields)
      end
    end

    sig { params(path: String, base_name: String, class_name: String, fields: T::Array[String]).void }
    def define_type(path:, base_name:, class_name:, fields:)
      File.write(path, "class #{class_name} < #{base_name.capitalize} \n", mode: 'a+')
      fields_list = fields.join(', ')
      File.write(path, "def initialize(#{fields_list})\n", mode: 'a+')

      fields.each do |field|
        File.write(path, "this.#{field} = #{field}\n", mode: 'a+')
      end
      File.write(path, "end\n", mode: 'a+')

      fields.each do |field|
        File.write(path, "attr_reader :#{field}\n", mode: 'a+')
      end
      File.write(path, "end\n", mode: 'a+')
    end
  end
end

GenerateAst.run
