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
            return to_string(cast(*LetStatement) node);
        case ReturnStatement;
            return to_string(cast(*ReturnStatement) node);
        case ExpressionStatement;
            return to_string(cast(*ExpressionStatement) node);
        case Identifier;
            return to_string(cast(*Identifier) node);
        case Boolean;
            return to_string(cast(*Boolean) node);
        case IntegerLiteral;
            return to_string(cast(*IntegerLiteral) node);
        case PrefixExpression;
            return to_string(cast(*PrefixExpression) node);
        case InfixExpression;
            return to_string(cast(*InfixExpression) node);
        case;
            return tprint("Error? to_string(*Node) not found: %", node.type);
    }
}

Statement :: struct {
    using #as base: Node;
}

Expression :: struct {
    using #as base: Node;
}

////////////////////////////
// Statements
LetStatement :: struct {
    using #as statement: Statement;
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
    using #as statement: Statement;
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
    using #as statement: Statement;
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
    using #as expression: Expression;
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
    using #as expression: Expression;
    value: bool;
}
NewBoolean :: (token: Token, value: bool) -> *Boolean {
    ret := NewNode(Boolean, token);
    ret.value = value;
    return ret;
}
to_string :: (i: $T) -> string {
    return i.token.literal;
}

IntegerLiteral :: struct {
    using #as expression: Expression;
    value: s64;
}
NewIntegerLiteral :: (token: Token, value: s64) -> *IntegerLiteral {
    ret := NewNode(IntegerLiteral, token);
    ret.value = value;
    return ret;
}

PrefixExpression :: struct {
    using #as expression: Expression;  // The prefix token, e.g. !
    op: string;
    right: *Expression;
}
NewPrefixExpression :: (token: Token, op: string, right: *Expression) -> *PrefixExpression {
    ret := NewNode(PrefixExpression, token);
    ret.op, ret.right = op, right;
    return ret;
}
to_string :: (p: *PrefixExpression) -> string {
    return tprint("(%0%0);", p.op, to_string(p.right));
}

InfixExpression :: struct {
    using #as expression: Expression;
    left: *Expression;
    op: string;
    right: *Expression;
}
NewInfixExpression :: (token: Token, left: *Expression, op: string, right: *Expression) -> *InfixExpression {
    ret := NewNode(InfixExpression, token);
    ret.left, ret.op, ret.right = left, op, right;
    return ret;
}
to_string :: (i: *InfixExpression) -> string {
    return tprint("(% % %)", to_string(i.left), i.op, to_string(i.right));
}
