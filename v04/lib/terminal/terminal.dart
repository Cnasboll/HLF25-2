
import 'dart:convert';
import 'dart:io';

import 'package:v04/terminal/colours.dart';

class Terminal {
  static void initialize() {
    stdout.encoding = utf8;
    stderr.encoding = utf8;
    stdout.write(
      '${Colours.clearScreen}${Colours.home}${Colours.green}',
    );
  }
  
  static void showPrompt() {
    // Fallback prompt that should work in PowerShell
    stdout.write('${Colours.green}> ');
  }
  
  static void println(String text) {
    // Keep green color without resetting
    print('${Colours.green}$text');
  }
  
  static String? readInput([String? promptText]) {
    if (promptText != null && promptText.isNotEmpty) {
      println(promptText);
    }
    showPrompt();
    var input = stdin.readLineSync(encoding: utf8);
    return input;
  }
  
  static void cleanup() {
    stdout.write('${Colours.reset}${Colours.showCursor}');
  }
}