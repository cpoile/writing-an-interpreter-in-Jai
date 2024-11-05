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
        print("parser error: %s\n", it);
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

Test_identifier_expressions :: () {
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
