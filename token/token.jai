#import "Basic";

TokenType :: enum {
    ILLEGAL;
    EOF;

    // Identifiers and literals
    IDENT;
    INT;

    // Operators
    ASSIGN;
    PLUS;
    MINUS;
    BANG;
    ASTERISK;
    SLASH;
    LT;
    GT;
    EQ;
    NOT_EQ;

    // Delimiters
    COMMA;
    SEMICOLON;
    LPAREN;
    RPAREN;
    LBRACE;
    RBRACE;

    // Keywords
    FUNCTION;
    LET;
    TRUE;
    FALSE;
    IF;
    ELSE;
    RETURN;
}

Token :: struct {
    type    : TokenType;
    literal : string;
}

operator == :: (a: Token, b: Token) -> bool {
    return a.type == b.type && equal(a.literal, b.literal);
}

operator != :: (a: Token, b: Token) -> bool {
    return a.type != b.type || !equal(a.literal, b.literal);
}
