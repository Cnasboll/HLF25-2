import 'dart:convert';
import 'dart:io';

String? readUtf8Line() {
  return stdin.readLineSync(encoding: utf8);
}

bool promptForYesNo(String prompt) {
  for (;;) {
    print('''

$prompt (y/n)''');
    var input = (readUtf8Line() ?? "").trim().toLowerCase();
    if (input.startsWith("y")) {
      return true;
    }
    if (input.startsWith("n")) {
      return false;
    }
    print("Invalid answer, please enter y or n");
  }
}

bool promptForYes(String prompt) {
  print('''

$prompt (y/N)''');
  var input = (readUtf8Line() ?? "").trim().toLowerCase();
  return input.startsWith("y");
}

enum YesNoCancel { yes, next, cancel }

YesNoCancel promptForYesNextCancel(String prompt) {
  for (;;) {
    print("$prompt (y = yes, n = next, c = cancel)");
    var input = (readUtf8Line() ?? "").trim().toLowerCase();
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
