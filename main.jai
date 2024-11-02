#import "Basic";
#import "String";
#load "lexer/lexer.jai";
#load "lexer/lexer_test.jai";

main :: () {
    // auto test for now.
    TestNextToken();

    print("Tests passed!");
}
