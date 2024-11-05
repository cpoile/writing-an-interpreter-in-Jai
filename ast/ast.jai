Program :: struct {
    statements: [..]*Statement; // TODO: should be just a struct?
}
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

Node :: struct {
    type:  Type;
    token: Token;
}
NewNode :: ($T: Type, token: Token) -> *T {
    ret: *T = alloc(size_of(T));
    ret.type, ret.token = T, token;
    return ret;
}
token_literal :: (node: $T) -> string { return node.token.literal; }
// Dispatch to proper node type:
to_string :: (node: *Node) -> string {
    if node.type == {
        case LetStatement;
            ls := cast(*LetStatement) node;
            return to_string(ls);
        case ReturnStatement;
            rs := cast(*ReturnStatement) node;
            return to_string(rs);
        case ExpressionStatement;
            es := cast(*ExpressionStatement) node;
            return to_string(es);
        case Identifier;
            i := cast(*Identifier) node;
            return to_string(i);
        case Boolean;
            b := cast(*Boolean) node;
            return to_string(b);
        case IntegerLiteral;
            il := cast(*IntegerLiteral) node;
            return to_string(il);
        case PrefixExpression;
            pe := cast(*PrefixExpression) node;
            return to_string(pe);
        case InfixExpression;
            ie := cast(*InfixExpression) node;
            return to_string(ie);
        case;
            return tprint("Error? to_string(*Node) not found: %", node.type);
    }
}

Statement :: struct {
    #as using base: Node;
}

Expression :: struct {
    #as using base: Node;
}

////////////////////////////
// Statements
LetStatement :: struct {
    #as using statement: Statement;
    name:  *Identifier;
    value: *Expression;
}
NewLetStatement :: (token: Token, name: *Identifier, value: *Expression) -> *LetStatement {
    ret := NewNode(LetStatement, token);
    ret.name, ret.value = name, value;
    return ret;
}
to_string :: (s: *LetStatement) -> string {
    value_string := ifx s.value  to_string(s.value);
    return tprint("% % = %;", token_literal(s), to_string(s.name), value_string);
}

ReturnStatement :: struct {
    #as using statement: Statement;
    return_value: *Expression;
}
NewReturnStatement :: (token: Token, return_value: *Expression) -> *ReturnStatement {
    ret := NewNode(ReturnStatement, token);
    ret.return_value = return_value;
    return ret;
}
to_string :: (s: *ReturnStatement) -> string {
    return_string := ifx s.return_value  to_string(s.return_value);
    return tprint("% %;", token_literal(s), return_string);
}

ExpressionStatement :: struct {
    #as using statement: Statement;
    expression: *Expression;
}
NewExpressionStatement :: (token: Token, expression: *Expression) -> *ExpressionStatement {
    ret := NewNode(ExpressionStatement, token);
    ret.expression = expression;
    return ret;
}
to_string :: (s: *ExpressionStatement) -> string {
    return ifx s.expression  to_string(s.expression);
}

///////////////////////////
// Expressions
Identifier :: struct {
    #as using expression: Expression;
    value: string;
}
NewIdentifier :: (token: Token, value: string) -> *Identifier {
    ret := NewNode(Identifier, token);
    ret.token, ret.value = token, value;
    return ret;
}
to_string :: (i: *Identifier) -> string {
    return i.value;
}

Boolean :: struct {
    #as using expression: Expression;
    value: bool;
}
NewBoolean :: (token: Token, value: bool) -> Boolean {
    ret := NewNode(Boolean, token);
    ret.value = value;
    return ret;
}
to_string :: (i: $T) -> string {
    return i.token.literal;
}

IntegerLiteral :: struct {
    #as using expression: Expression;
    value: s64;
}
NewIntegerLiteral :: (token: Token, value: s64) -> IntegerLiteral {
    ret := NewNode(IntegerLiteral, token);
    ret.value = value;
    return ret;
}

PrefixExpression :: struct {
    #as using expression: Expression;  // The prefix token, e.g. !
    op: string;
    right: Expression;
}
NewPrefixExpression :: (token: Token, op: string, right: Expression) -> PrefixExpression {
    ret := NewNode(PrefixExpression, token);
    ret.op, ret.right = op, right;
    return ret;
}
to_string :: (p: *PrefixExpression) -> string {
    return tprint("(%0%0);", p.op, to_string(p.right));
}

InfixExpression :: struct {
    #as using expression: Expression;
    left: Expression;
    op: string;
    right: Expression;
}
NewInfixExpression :: (token: Token, left: Expression, op: string, right: Expression) -> InfixExpression {
    ret := NewNode(InfixExpression, token);
    ret.left, ret.op, ret.right = left, op, right;
    return ret;
}
to_string :: (i: *InfixExpression) -> string {
    return tprint("(% % %)", to_string(i.left), i.op, to_string(i.right));
}
