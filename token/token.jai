#import "Basic";

TokenType :: enum {
    ILLEGAL;
    EOF;
    // Identifiers + literals
    IDENT;
    INT;

    // Operators
    ASSIGN;
    PLUS;
    // Delimiters
    COMMA;
    SEMICOLON;

    PAREN;
    LPAREN;
    RPAREN;
    LBRACE;
    RBRACE;

    // Keywords
    FUNCTION;
    LET;
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
