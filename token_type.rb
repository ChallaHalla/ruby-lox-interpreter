class TokenType < T::Enum
  enums do
    LEFT_PAREN = new
    RIGHT_PAREN = new
    LEFT_BRACE = new
    RIGHT_BRACE = new

    COMMA = new
    DOT = new
    MINUS = new
    PLUS = new
    SEMICOLON = new
    SLASH = new
    STAR = new

    BANG = new
    BANG_EQUAL = new

    EQUAL = new
    EQUAL_EQUAL = new

    GREATER = new
    GREATER_EQUAL = new

    LESS = new
    LESS_EQUAL = new

    IDENTIFIER = new
    STRING = new
    NUMBER = new

    AND = new
    CLASS = new
    ELSE = new
    FALSE = new
    FUN = new
    FOR = new
    IF = new
    NIL = new
    OR = new

    PRINT = new
    RETURN = new
    SUPER = new
    THIS = new
    TRUE = new
    VAR = new
    WHILE = new

    EOF = new
  end
end
