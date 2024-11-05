Precedence :: enum {
    LOWEST;
    EQUALS;       // ==
    LESSGREATER;  // < or >
    SUM;          // +
    PRODUCT;      // *
    PREFIX;       // -X or !X
    CALL;         // myFunction(X)
}

Parser :: struct {
    lexer      : *Lexer;
    cur_token  : Token;
    peek_token : Token;
    errors     : [..]string;
}

prefix_parse_fn :: #type (*Parser) -> *Expression;
infix_parse_fn  :: #type (*Parser, *Expression) -> *Expression;

prefix_parse_fns : [TokenType.TYPE_COUNT] prefix_parse_fn;
infix_parse_fns  : [TokenType.TYPE_COUNT] infix_parse_fn;

register_prefix :: (t: TokenType, fn: prefix_parse_fn) {
    prefix_parse_fns[t] = fn;
}
register_infix :: (t: TokenType, fn: infix_parse_fn) {
    infix_parse_fns[t] = fn;
}

NewParser :: (l: *Lexer) -> *Parser {
    p := New(Parser);
    p.lexer = l;

    register_prefix(.IDENT, parse_identifier);

    // Read two tokens, so curToken and peekToken are both set
    next_token(p);
    next_token(p);

    return p;
}

next_token :: (p: *Parser) {
    p.cur_token = p.peek_token;
    p.peek_token = next_token(p.lexer);
}

parse_program :: (p: *Parser) -> *Program {
    program := New(Program);

    while !cur_token_is(p, .EOF) {
        stmt := parse_statement(p);
        if stmt  array_add(*program.statements, stmt);
        next_token(p);
    }

    return program;
}

parse_statement :: (p: *Parser) -> *Statement {
    if p.cur_token.type == {
        case .LET;
            return parse_let_statement(p);
        case .RETURN;
            return parse_return_statement(p);
        case;
            return parse_expression_statement(p);
    }
}

parse_let_statement :: (p: *Parser) -> *LetStatement {
    token := p.cur_token;

    if !expect_peek(p, .IDENT) return null;

    name := NewIdentifier(p.cur_token, p.cur_token.literal);

    if !expect_peek(p, .ASSIGN) {
        free(name);
        return null;
    }

    // TODO: we're skipping the expressions until we get a semicolon
    while !cur_token_is(p, .SEMICOLON) {
        next_token(p);
    }

    return NewLetStatement(token, name, null);
}

parse_return_statement :: (p: *Parser) -> *ReturnStatement {
    stmt := NewReturnStatement(p.cur_token, null);

    // TODO: we're skipping the expressions until we get a semicolon
    while !cur_token_is(p, .SEMICOLON) {
        next_token(p);
    }

    return stmt;
}

parse_expression_statement :: (p: *Parser) -> *ExpressionStatement {
    stmt := NewExpressionStatement(p.cur_token, null);

    stmt.expression = parse_expression(p, cast(int) Precedence.LOWEST);

    if peek_token_is(p, .SEMICOLON) {
        next_token(p);
    }

    return stmt;
}

parse_expression :: (p: *Parser, precendence: int) -> *Expression {
    prefix := prefix_parse_fns[p.cur_token.type];
    if !prefix  return null;
    left_exp := prefix(p);

    return left_exp;
}

parse_identifier :: (p: *Parser) -> *Expression {
    return NewIdentifier(p.cur_token, p.cur_token.literal);
}

cur_token_is :: (p: *Parser, t: TokenType) -> bool {
    return p.cur_token.type == t;
}

peek_token_is :: (p: *Parser, t: TokenType) -> bool {
    return p.peek_token.type == t;
}

expect_peek :: (p: *Parser, t: TokenType) -> bool {
    if peek_token_is(p, t) {
        next_token(p);
        return true;
    }
    peek_error(p, t);
    return false;
}

peek_error :: (p: *Parser, t: TokenType) {
    msg := sprint("expected next token to be %, got % instead", t, p.peek_token.type);
    array_add(*p.errors, msg);
}
