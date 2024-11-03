StatementType :: enum {
    LET;
    RETURN;
    EXPRESSION;
}

Program :: struct {
    statements: [..]Statement;
}

Statement :: struct {
    type:  StatementType;
    token: Token;
    name:  *Identifier;
    expr:  *Identifier;
}

// Identifier represents an Identifier (x in let x = expression) and an expression (the expression... I think... haven't done that yet.)
Identifier :: struct {
    token: Token;
    value: string;
}

NewIdentifier :: (token: Token, value: string) -> *Identifier {
    ret := New(Identifier);
    ret.token = token;
    ret.value = value;
    return ret;
}

// Program:
token_literal :: (p: Program) -> string {
    if p.statements.count > 0  return token_literal(p.statements[0]);
    return "";
}

to_string :: (p: Program) -> string {
    builder: String_Builder;
    builder.allocator = __temporary_allocator;

    for p.statements {
        print_to_builder(*builder, to_string(it));
    }

    return builder_to_string(*builder,, allocator = __temporary_allocator);
}

// Identments (Identifiers + Statements):
token_literal :: (identment: $T) -> string { return identment.token.literal; }

to_string :: (statement: Statement) -> string {
    builder: String_Builder;
    builder.allocator = __temporary_allocator;

    name := ifx statement.name  to_string(statement.name);
    expr_string := ifx statement.expr  to_string(statement.expr);
    print_to_builder(*builder, "% % = %;", token_literal(statement), name, expr_string);

    return builder_to_string(*builder,, allocator = __temporary_allocator);
}

to_string :: (ident: Identifier) -> string {return ident.value; }
