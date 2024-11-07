Test_let_statement :: () {
    input :: #string END
let x = 5;
let y = 10;
let foobar = 838383;
END

    l := NewLexer(input);
    p := NewParser(l);

    program := parse_program(p);
    check_parse_errors(p);

    assert_not_null(program);

    assert_equal(3, program.statements.count);

    tests := struct {
        expectedIdent: string;
    }.[
        .{"x"},
        .{"y"},
        .{"foobar"},
    ];

    for tests {
        stmt := program.statements[it_index];
        if !test_let_statement(it.expectedIdent, stmt) {
            assert(test_let_statement(it.expectedIdent, stmt));
        }
    }
}

test_let_statement :: (expected: string, actual: *Statement) -> bool {
    assert_equal(LetStatement, actual.type);
    stmt := cast(*LetStatement) actual;
    assert_equal(expected, stmt.name.value);
    assert_equal(expected, token_literal(stmt.name));

    return true;
}

assert_not_null :: (actual: $T) {
    if !actual {
        node := context.stack_trace.next;
        print("%:%:  assertion failed: expected not null, but was null\n", node.info.location.fully_pathed_filename, node.line_number);
        assert(actual != null);
    }
}
assert_equal :: (expected: $T, actual: T) {
    if expected != actual {
        node := context.stack_trace.next;
        print("%:%:  assertion failed: expected: %   got: %\n", node.info.location.fully_pathed_filename, node.line_number, expected, actual,);
        assert(expected == actual);
    }
}

check_parse_errors :: (p: *Parser) {
    errors := p.errors;
    if errors.count == 0 {
        return;
    }

    print("parser has % errors:\n", errors.count);
    for errors {
        print("parser error: %\n", it);
    }
    assert(errors.count == 0);
}

Test_return_statement :: () {
    input :: #string END
return 5;
return 10;
return 99323141;
END

    l := NewLexer(input);
    p := NewParser(l);

    program := parse_program(p);
    check_parse_errors(p);
    assert_not_null(program);

    assert_equal(3, program.statements.count);

    for program.statements {
        assert_equal(ReturnStatement, it.type);
        assert_equal("return", token_literal(it));
    }
}

Test_expressions :: () {
    test_identifier_expressions();
    test_integer_literal_expressions();
    test_prefix_expressions();
    test_infix_expressions();
}

test_identifier_expressions :: () {
    input := "foobar;";

    l := NewLexer(input);
    p := NewParser(l);

    program := parse_program(p);
    check_parse_errors(p);
    assert_not_null(program);

    assert_equal(1, program.statements.count);

    for program.statements {
        assert_equal(ExpressionStatement, it.type);
        es := cast(*ExpressionStatement) it;
        assert_equal(Identifier, es.expression.type);
        ident := cast(*Identifier) es.expression;
        assert_equal("foobar", ident.value);
        assert_equal("foobar", token_literal(ident));
    }
}

test_integer_literal_expressions :: () {
    input := "5;";

    l := NewLexer(input);
    p := NewParser(l);

    program := parse_program(p);
    check_parse_errors(p);
    assert_not_null(program);

    assert_equal(1, program.statements.count);

    for program.statements {
        assert_equal(ExpressionStatement, it.type);
        es := cast(*ExpressionStatement) it;
        test_integer_literal(5, es.expression);
    }
}

test_integer_literal :: (expected: s64, actual: *Expression) {
    assert_equal(IntegerLiteral, actual.type);
    lit := cast(*IntegerLiteral) actual;
    assert_equal(expected, lit.value);
    assert_equal(tprint("%", expected), token_literal(lit));
}

test_prefix_expressions :: () {
    cases := struct{
        input:   string;
        op:      string;
        int_val: s64;
    }.[
        .{"!5;", "!", 5},
        .{"-15", "-", 15},
    ];

    for cases {
        l := NewLexer(it.input);
        p := NewParser(l);

        program := parse_program(p);
        check_parse_errors(p);
        assert_not_null(program);
        assert_equal(1, program.statements.count);

        stmt := program.statements[0];
        assert_equal(ExpressionStatement, stmt.type);
        es := cast(*ExpressionStatement) stmt;
        assert_equal(PrefixExpression, es.expression.type);
        exp := cast(*PrefixExpression) es.expression;
        assert_equal(it.op, exp.op);
        test_integer_literal(it.int_val, exp.right);
    }
}

test_infix_expressions :: () {
    cases := struct{
        input:   string;
        left:    s64;
        op:      string;
        right:   s64;
    }.[
        .{"5 + 5;", 5, "+", 5},
        .{"5 - 5;", 5, "-", 5},
        .{"5 * 5;", 5, "*", 5},
        .{"5 / 5;", 5, "/", 5},
        .{"5 > 5;", 5, ">", 5},
        .{"5 < 5;", 5, "<", 5},
        .{"5 == 5;", 5, "==", 5},
        .{"5 != 5;", 5, "!=", 5},
    ];

    for cases {
        l := NewLexer(it.input);
        p := NewParser(l);

        program := parse_program(p);
        check_parse_errors(p);
        assert_not_null(program);
        assert_equal(1, program.statements.count);

        stmt := program.statements[0];
        assert_equal(ExpressionStatement, stmt.type);
        es := cast(*ExpressionStatement) stmt;
        assert_equal(InfixExpression, es.expression.type);
        exp := cast(*InfixExpression) es.expression;
        assert_equal(it.op, exp.op);
        test_integer_literal(it.left, exp.left);
        test_integer_literal(it.right, exp.right);
    }
}
