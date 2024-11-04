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

prefix_parse_fn :: #type () -> Statement;
infix_parse_fn  :: #type (Statement) -> Statement;

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
        stmt, ok := parse_statement(p);
        if ok  array_add(*program.statements, stmt);
        next_token(p);
    }

    return program;
}

parse_statement :: (p: *Parser) -> Statement, bool {
    if p.cur_token.type == {
        case .LET;
            stmt, ok := parse_let_statement(p);
            return stmt, ok;
        case .RETURN;
            stmt, ok := parse_return_statement(p);
            return stmt, ok;
        case;
            stmt, ok := parse_expression_statement(p);
            return stmt, ok;
    }
}

parse_let_statement :: (p: *Parser) -> Statement, bool {
    stmt := Statement.{type = .LET, token = p.cur_token};

    if !expect_peek(p, .IDENT) return stmt, false;

    stmt.name = NewIdentifier(token = p.cur_token, value = p.cur_token.literal);

    if !expect_peek(p, .ASSIGN) return stmt, false;

    // TODO: we're skipping the expressions until we get a semicolon
    while !cur_token_is(p, .SEMICOLON) {
        next_token(p);
    }

    return stmt, true;
}

parse_return_statement :: (p: *Parser) -> Statement, bool {
    stmt := Statement.{type = .RETURN, token = p.cur_token};

    // TODO: we're skipping the expressions until we get a semicolon
    while !cur_token_is(p, .SEMICOLON) {
        next_token(p);
    }

    return stmt, true;
}

parse_expression_statement :: (p: *Parser) -> Statement, bool {
    stmt := Statement.{type = .EXPRESSION, token= p.cur_token};

    // stmt.expr = parse_expression(p, cast(int) Precedence.LOWEST);

    if peek_token_is(p, .SEMICOLON) {
        next_token(p);
    }

    return stmt, false;
}

parse_expression :: (p: *Parser, precendence: int) -> Statement, bool {
    prefix := prefix_parse_fns[p.cur_token.type];
    if !prefix  return .{}, false;
    left_exp := prefix();

    return left_exp, true;
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
