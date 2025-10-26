import 'package:v04/terminal/terminal.dart';

String promptFor(String promptText, [String defaultValue = '']) {
  var input = Terminal.readInput(promptText) ?? defaultValue;
  return input.isEmpty ? defaultValue : input;
}

bool promptForYesNo(String prompt) {
  for (;;) {
    var input = promptFor('''

$prompt (y/n)''');
    if (input.startsWith("y")) {
      return true;
    }
    if (input.startsWith("n")) {
      return false;
    }
    Terminal.println("Invalid answer, please enter y or n");
  }
}

enum YesNoAllQuit { yes, no, all, quit }

YesNoAllQuit promptForYesNoAllQuit(String prompt) {
  for (;;) {
    var input = promptFor('''

$prompt (y = yes, n = no, a = all, q = quit)''').toLowerCase();
    if (input.startsWith("y")) {
      return YesNoAllQuit.yes;
    }
    if (input.startsWith("n")) {
      return YesNoAllQuit.no;
    }
    if (input.startsWith("a")) {
      return YesNoAllQuit.all;
    }
    if (input.startsWith("q")) {
      return YesNoAllQuit.quit;
    }
    Terminal.println("Invalid answer, please enter y or n");
  }
}

bool promptForYes(String prompt) {
  return promptFor('''

$prompt (y/N)''', 'N').toLowerCase().startsWith('y');
}

bool promptForNo(String prompt) {
  return !(promptFor('''

$prompt (Y/n)''', 'Y').toLowerCase()).startsWith('n');
}

enum YesNextCancel { yes, next, cancel }

YesNextCancel promptForYesNextCancel(String prompt) {
  for (;;) {
    var input = promptFor("$prompt (y = yes, n = next, c = cancel)");
    if (input.startsWith("y")) {
      return YesNextCancel.yes;
    }
    if (input.startsWith("n")) {
      return YesNextCancel.next;
    }
    if (input.startsWith("c")) {
      return YesNextCancel.cancel;
    }
    Terminal.println("Invalid answer, please enter y, n or c");
  }
}
