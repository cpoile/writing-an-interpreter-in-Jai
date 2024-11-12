#import "Windows";

PROMPT :: ">> ";

read_line :: (h: HANDLE) -> string {
    buffer: [4096]u8;
    bytes_read: u32;
    success := ReadFile(h, buffer.data, buffer.count, *bytes_read, null);
    return tprint(to_string(buffer.data, bytes_read));
}

start_repl :: (h: HANDLE) {

    while true {
        print(PROMPT);
        input := read_line(h);

        if input.count == 0 {
            print("\nGoodbye!");
            return;
        }

        l := NewLexer(input);

        tok := next_token(l);
        while tok.type != .EOF && tok.type != .ILLEGAL {
            print("%\n", tok);
            tok = next_token(l);
        }
    }
}
