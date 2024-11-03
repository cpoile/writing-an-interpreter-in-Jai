Test_ast_string :: () {
    program : Program;
    array_add(*program.statements, Statement.{
        type = StatementType.LET,
        token = Token.{.LET, "let"},
        name = NewIdentifier(Token.{IDENT, "myVar"}, value = "myVar"),
        expr = NewIdentifier(Token.{IDENT, "anotherVar"}, value = "anotherVar"),
    });

    assert_equal("let myVar = anotherVar;", to_string(program));
}
