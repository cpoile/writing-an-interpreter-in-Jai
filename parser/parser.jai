Precedence :: enum {
    LOWEST;
    EQNOTEQ;      // == or !=
    LESSGREATER;  // < or >
    SUMDIFF;      // + or -
    PRODUCTDIV;   // * or /
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
    register_prefix(.INT, parse_integer);
    register_prefix(.BANG, parse_prefix_expression);
    register_prefix(.MINUS, parse_prefix_expression);
    register_infix(.PLUS, parse_infix_expression);
    register_infix(.MINUS, parse_infix_expression);
    register_infix(.ASTERISK, parse_infix_expression);
    register_infix(.SLASH, parse_infix_expression);
    register_infix(.LT, parse_infix_expression);
    register_infix(.GT, parse_infix_expression);
    register_infix(.EQ, parse_infix_expression);
    register_infix(.NOT_EQ, parse_infix_expression);

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
    if !prefix {
        msg := sprint("no prefix parse function for % found", p.cur_token.type);
        array_add(*p.errors, msg);
        return null;
    }
    left_exp := prefix(p);

    infix := infix_parse_fns[p.peek_token.type];
    if !infix {
        return left_exp;
    }
    next_token(p);

    return infix(p, left_exp);
}

parse_identifier :: (p: *Parser) -> *Expression {
    return NewIdentifier(p.cur_token, p.cur_token.literal);
}

parse_integer :: (p: *Parser) -> *Expression {
    res, ok, _ := to_integer(p.cur_token.literal);
    if !ok {
        msg := sprint("could not parse % as integer", p.cur_token.literal);
        array_add(*p.errors, msg);
        return null;
    }
    return NewIntegerLiteral(p.cur_token, res);
}

parse_prefix_expression :: (p: *Parser) -> *Expression {
    prefix_token := p.cur_token;

    next_token(p);

    right := parse_expression(p, cast(int) Precedence.PREFIX);

    return NewPrefixExpression(prefix_token, prefix_token.literal, right);
}

parse_infix_expression :: (p: *Parser, left: *Expression) -> *Expression {
    infix_token := p.cur_token;

    next_token(p);

    precedence := precedence_for_token(infix_token.type);
    if precedence < 0 {
        msg := sprint("bad precedence operator: %", infix_token.type);
        array_add(*p.errors, msg);
        return null;
    }

    right := parse_expression(p, precedence);

    return NewInfixExpression(infix_token, left, infix_token.literal, right);
}

// Parsing utilities:
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

precedence_for_token :: (t: TokenType) -> int {
    if t == {
        case .EQ; #through;
        case .NOT_EQ;
            return cast(int) Precedence.EQNOTEQ;
        case .LT;  #through;
        case .GT;
            return cast(int) Precedence.LESSGREATER;
        case .PLUS; #through;
        case .MINUS;
            return cast(int) Precedence.SUMDIFF;
        case .ASTERISK; #through;
        case .SLASH;
            return cast(int) Precedence.PRODUCTDIV;
        case;
            return -1;
    }
}
