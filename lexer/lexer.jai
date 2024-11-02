#load "../token/token.jai";
#load "print_char.jai";

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

peakChar :: (l: *Lexer) -> u8 {
    if (l.readPosition >= l.input.count) return 0;
    return l.input[l.readPosition];
}

isLetter :: (char: u8) -> bool {
    return 65 <= char && char <= 90 || 97 <= char && char <= 122 || char == 95;
}

isDigit :: (char: u8) -> bool {
    return 48 <= char && char <= 57;
}


readIdentifier :: (l: *Lexer) -> string {
    position := l.position;
    while isLetter(l.ch) {
        readChar(l);
    }
    return .{data = *l.input[position], count = l.position - position};
}

// TODO: combine with above
readNumber :: (l: *Lexer) -> string {
    position := l.position;
    while isDigit(l.ch) {
        readChar(l);
    }
    str: string;
    str.data = *l.input[position];
    str.count = l.position - position;
    return str;
}

lookupIdentifier :: (ident: string) -> TokenType {
    if ident == {
        case "fn";
            return FUNCTION;
        case "let";
            return LET;
        case "true";
            return TRUE;
        case "false";
            return FALSE;
        case "if";
            return IF;
        case "else";
            return ELSE;
        case "return";
            return RETURN;
        case;
            return IDENT;
    }
}

skipWhitespace :: (l: *Lexer) {
    while l.ch == #char " " || l.ch == #char "\t" || l.ch == #char "\n" || l.ch == #char "\r" {
        readChar(l);
    }
}

nextToken :: (l: *Lexer) -> Token {
    skipWhitespace(l);
    tok: Token;

    if l.ch == {
        case #char "=";
            if peakChar(l) == #char "=" {
                tok = Token.{EQ, "=="};
                readChar(l);
            } else tok = Token.{ASSIGN, "="};
        case #char "!";
            if peakChar(l) == #char "=" {
                tok = Token.{NOT_EQ, "!="};
                readChar(l);
            } else tok = Token.{BANG, "!"};
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
        case #char "-";
            tok = Token.{MINUS, "-"};
        case #char "{";
            tok = Token.{LBRACE, "{"};
        case #char "}";
            tok = Token.{RBRACE, "}"};
        case #char "/";
            tok = Token.{SLASH, "/"};
        case #char "*";
            tok = Token.{ASTERISK, "*"};
        case #char "<";
            tok = Token.{LT, "<"};
        case #char ">";
            tok = Token.{GT, ">"};
        case 0;
            tok = Token.{EOF, ""};
        case;
            if isLetter(l.ch) {
                tok.literal = readIdentifier(l);
                tok.type = lookupIdentifier(tok.literal);
                return tok;
            } else if isDigit(l.ch) {
                tok.literal = readNumber(l);
                tok.type = INT;
                return tok;
            } else {
                return Token.{ILLEGAL, Char_Table[l.ch]};
            }

    }

    readChar(l);
    return tok;
}
