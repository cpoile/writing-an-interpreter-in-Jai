#import "Basic";
#import "String";
#load "lexer.jai";
#load "lexer_test.jai";
#load "repl.jai";
#load "ast.jai";
#load "ast_test.jai";
#load "parser.jai";
#load "parser_test.jai";

main :: () {
    args := get_command_line_arguments();
    if args.count > 1 && args[1] == "test" {
        Test_next_token();
        Test_let_statement();
        Test_return_statement();
        Test_ast_string();
        Test_expressions();
        print("Tests passed!");
        return;
    }

    user_name: [128]u8;
    count : u32 = 128;
    success := GetUserNameA(user_name.data, *count);
    if !success {
        print("Error getting username.\n");
        return;
    }

    print("Hello %! This is the Monkey programming language!\nFeel free to type in commands.\n", to_string(user_name.data, count-1));
    stdin_handle := GetStdHandle(STD_INPUT_HANDLE);

    start_repl(stdin_handle);
}
