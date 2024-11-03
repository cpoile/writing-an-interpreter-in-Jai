StatementType :: enum {
    LET;
    RETURN;
}

Program :: struct {
    statements: [..]Statement;
}

Statement :: struct {
    type:  StatementType;
    token: Token;
    expr:  *Identifier;
}

// Identifier represents an Identifier (x in let x = expression) and an expression (the expression... I think... haven't done that yet.)
Identifier :: struct {
    token: Token;
    value: string;
}

token_literal :: (p: Program) -> string {
    if p.statements.count > 0  return token_literal(p.statements[0]);
    return "";
}

// identment is an Indentifier or a Statement (really anything that has a token, I guess)
token_literal :: (identment: $T) -> string { return identment.token.literal; }
