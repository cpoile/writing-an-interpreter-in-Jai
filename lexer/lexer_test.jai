
using TokenType;

TestNextToken :: () {
    input := #string END
let five = 5;
let ten = 10;

let add = fn(x, y) {
    x + y;
};
END

    expectedTokens := Token.[
        .{LET, "let"},     .{IDENT, "five"},    .{ASSIGN, "="},    .{INT, "5"},        .{SEMICOLON, ";"}, .{LET, "let"},
        .{IDENT, "ten"},   .{ASSIGN, "="},      .{INT, "10"},      .{SEMICOLON, ";"},  .{LET, "let"},     .{IDENT, "add"},
        .{ASSIGN, "="},    .{FUNCTION, "fn"},   .{LPAREN, "("},    .{IDENT, "x"},      .{COMMA, ","},     .{IDENT, "y"},
        .{RPAREN, ")"},    .{LBRACE, "{"},      .{IDENT, "x"},     .{PLUS, "+"},       .{IDENT, "y"},     .{SEMICOLON, ";"},
        .{RBRACE, "}"},    .{SEMICOLON, ";"},   .{EOF, ""},
    ];

    l := NewLexer(input);

    for expectedTokens {
        tok := nextToken(l);
        if tok != it {
            print("Assertion failed, wanted: % got: %\n", it, tok);
            assert (tok == it);
        }
    }
}
