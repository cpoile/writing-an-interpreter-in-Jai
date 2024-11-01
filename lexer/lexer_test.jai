
using TokenType;

TestNextToken :: () {
    input := #string END
=+(){},;
END

    expectedTokens := Token.[
            .{ASSIGN, "="}, .{PLUS, "+"}, .{LPAREN, "("}, .{RPAREN, ")"}, .{LBRACE, "{"}, .{RBRACE, "}"},
            .{COMMA, ","}, .{SEMICOLON, ";"}
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
