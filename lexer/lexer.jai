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
    read_char(l);
    return l;
}

read_char :: (l: *Lexer) {
    if (l.readPosition >= l.input.count) l.ch = 0;
    else l.ch = l.input[l.readPosition];
    l.position = l.readPosition;
    l.readPosition += 1;
}

peak_char :: (l: *Lexer) -> u8 {
    if (l.readPosition >= l.input.count) return 0;
    return l.input[l.readPosition];
}

is_letter :: (char: u8) -> bool {
    return #char "a" <= char && char <= #char "z" || #char "A" <= char && char <= #char "Z" || char == #char "_";
}

is_my_digit :: (char: u8) -> bool {
    return #char "0" <= char && char <= #char "9";
}


read_ident_or_num :: (l: *Lexer, decider: (u8) -> bool) -> string {
    position := l.position;
    while decider(l.ch) {
        read_char(l);
    }
    return .{data = *l.input[position], count = l.position - position};
}

lookup_identifier :: (ident: string) -> TokenType {
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

skip_whitespace :: (l: *Lexer) {
    while l.ch == #char " " || l.ch == #char "\t" || l.ch == #char "\n" || l.ch == #char "\r" {
        read_char(l);
    }
}

next_token :: (l: *Lexer) -> Token {
    skip_whitespace(l);
    tok: Token;

    if l.ch == {
        case #char "=";
            if peak_char(l) == #char "=" {
                tok = Token.{EQ, "=="};
                read_char(l);
            } else tok = Token.{ASSIGN, "="};
        case #char "!";
            if peak_char(l) == #char "=" {
                tok = Token.{NOT_EQ, "!="};
                read_char(l);
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
            if is_letter(l.ch) {
                tok.literal = read_ident_or_num(l, is_letter);
                tok.type = lookup_identifier(tok.literal);
                return tok;
            } else if is_my_digit(l.ch) {
                tok.literal = read_ident_or_num(l, is_digit);
                tok.type = INT;
                return tok;
            } else {
                return Token.{ILLEGAL, Char_Table[l.ch]};
            }

    }

    read_char(l);
    return tok;
}
