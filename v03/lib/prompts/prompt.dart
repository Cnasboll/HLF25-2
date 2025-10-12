import 'dart:io';

bool promptForYesNo(String prompt) {
  for (;;) {
    print('''

$prompt (y/n)''');
    var input = (stdin.readLineSync() ?? "").trim().toLowerCase();
    if (input.startsWith("y")) {
      return true;
    }
    if (input.startsWith("n")) {
      return false;
    }
    print("Invalid answer, please enter y or n");
  }
}

enum YesNoCancel { yes, next, cancel }

YesNoCancel promptForYesNextCancel(String prompt) {
  for (;;) {
    print("$prompt (y = yes, n = next, c = cancel)");
    var input = (stdin.readLineSync() ?? "").trim().toLowerCase();
    if (input.startsWith("y")) {
      return YesNoCancel.yes;
    }
    if (input.startsWith("n")) {
      return YesNoCancel.next;
    }
    if (input.startsWith("c")) {
      return YesNoCancel.cancel;
    }
    print("Invalid answer, please enter y, n or c");
  }
}
