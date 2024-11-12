NP :: "NONPRINTABLE";

Char_Table :: string.[
    // 0-8 non-printable
    NP, NP, NP, NP, NP, NP, NP, NP, NP,
    "\t", "\n",
    // 11 is vertical tab (\v), 12 is form feed (\f)
    "", "",
    "\r",
    // 14-31 non-printable
    NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, NP, 
    " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?",
    "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_",
    "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~",
];

// main :: () {
//     for 0..126 {
//         print("% is %\n", it, Char_Table[it]);
//     }

// }


// #import "Basic";
