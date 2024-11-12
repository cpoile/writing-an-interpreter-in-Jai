Test_ast_string :: () {
    program : Program;
    array_add(*program.statements, NewLetStatement(
        token = Token.{.LET, "let"},
        name = NewIdentifier(Token.{.IDENT, "myVar"}, "myVar"),
        value = NewIdentifier(Token.{.IDENT, "anotherVar"}, "anotherVar"),
    ));

    assert_equal("let myVar = anotherVar;", to_string(program));
}
