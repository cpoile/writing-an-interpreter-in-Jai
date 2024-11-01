#load "../token/token.jai";

Lexer :: struct {
    input        : string;
    position     : u32;
    readPosition : u32;
    ch           : u8;
}

NewLexer :: (in: string) -> *Lexer {
    l := New(Lexer);
    l.input = in;
    readChar(l);
    return l;
}

readChar :: (l: *Lexer) {
    if (l.readPosition >= l.input.count) l.ch = 0;
    else l.ch = l.input[l.readPosition];
    l.position = l.readPosition;
    l.readPosition += 1;
}

nextToken :: (l: *Lexer) -> Token {
    tok: Token;

    if l.ch == {
        case #char "=";
            tok = Token.{ASSIGN, "="};
        case #char ";";
            tok = Token.{SEMICOLON, ";"};
        case #char "(";
            tok = Token.{LPAREN, "("};
        case #char ")";
            tok = Token.{RPAREN, ")"};
        case #char ",";
            tok = Token.{COMMA, ","};
        case #char "+";
            tok = Token.{PLUS, "+"};
        case #char "{";
            tok = Token.{LBRACE, "{"};
        case #char "}";
            tok = Token.{RBRACE, "}"};
        case 0;
            tok = Token.{EOF, ""};
    }

    readChar(l);
    return tok;
}
