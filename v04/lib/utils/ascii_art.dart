import 'dart:math';

/// Simple ASCII art converter for hero images
class AsciiArt {
  static const String _grayScale = ' .:-=+*#%@';

  /// Creates ASCII art from hero image URL (simulated for demo)
  static String createHeroPortrait(String heroName) {
    final random = Random(heroName.hashCode);
    final lines = <String>[];

    // Create a simple 20x10 ASCII portrait based on hero name
    for (int y = 0; y < 10; y++) {
      String line = '';
      for (int x = 0; x < 20; x++) {
        // Create a simple pattern based on position and hero name
        final intensity = _calculateIntensity(x, y, heroName, random);
        final charIndex = (intensity * (_grayScale.length - 1)).round();
        line += _grayScale[charIndex];
      }
      lines.add(line);
    }

    return lines.join('\n');
  }

  /// Calculate intensity for ASCII character selection
  static double _calculateIntensity(
    int x,
    int y,
    String heroName,
    Random random,
  ) {
    // Create a face-like pattern
    final centerX = 10;
    final centerY = 5;
    final distanceFromCenter = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));

    // Eyes
    if ((x == 7 || x == 13) && y == 3) return 1.0;

    // Nose
    if (x == 10 && y == 5) return 0.8;

    // Mouth
    if ((x >= 8 && x <= 12) && y == 7) return 0.9;

    // Face outline
    if (distanceFromCenter > 6 && distanceFromCenter < 8) return 0.6;

    // Hair (top)
    if (y <= 2 && distanceFromCenter < 7)
      return 0.7 + random.nextDouble() * 0.3;

    // Face interior
    if (distanceFromCenter < 6) return 0.2 + random.nextDouble() * 0.3;

    // Background
    return random.nextDouble() * 0.2;
  }

  /// Create ASCII banner text
  static String createBanner(String text) {
    if (text.isEmpty) return '';

    final lines = List.generate(5, (_) => StringBuffer());

    for (final char in text.toUpperCase().runes) {
      final charStr = String.fromCharCode(char);
      final pattern = _getCharPattern(charStr);

      for (int i = 0; i < 5; i++) {
        lines[i].write(pattern[i]);
        if (char != text.toUpperCase().runes.last) {
          lines[i].write(' '); // Space between characters
        }
      }
    }

    return lines.map((line) => line.toString()).join('\n');
  }

  /// Get ASCII pattern for a character (complete font)
  static List<String> _getCharPattern(String char) {
    switch (char) {
      // Alphabet A-Z
      case 'A':
        return ['  ██  ', ' █  █ ', '██████', '█    █', '█    █'];
      case 'B':
        return ['█████ ', '█    █', '█████ ', '█    █', '█████ '];
      case 'C':
        return [' █████', '█     ', '█     ', '█     ', ' █████'];
      case 'D':
        return ['████  ', '█   █ ', '█    █', '█   █ ', '████  '];
      case 'E':
        return ['██████', '█     ', '█████ ', '█     ', '██████'];
      case 'F':
        return ['██████', '█     ', '█████ ', '█     ', '█     '];
      case 'G':
        return [' █████', '█     ', '█  ███', '█    █', ' █████'];
      case 'H':
        return ['█    █', '█    █', '██████', '█    █', '█    █'];
      case 'I':
        return ['██████', '  ██  ', '  ██  ', '  ██  ', '██████'];
      case 'J':
        return ['██████', '    █ ', '    █ ', '█   █ ', ' █████'];
      case 'K':
        return ['█   █ ', '█  █  ', '███   ', '█  █  ', '█   █ '];
      case 'L':
        return ['█     ', '█     ', '█     ', '█     ', '██████'];
      case 'M':
        return ['█    █', '██  ██', '█ ██ █', '█    █', '█    █'];
      case 'N':
        return ['█    █', '██   █', '█ █  █', '█  █ █', '█   ██'];
      case 'O':
        return [' █████', '█    █', '█    █', '█    █', ' █████'];
      case 'P':
        return ['█████ ', '█    █', '█████ ', '█     ', '█     '];
      case 'Q':
        return [' █████', '█    █', '█ █  █', '█  █ █', ' ██████'];
      case 'R':
        return ['█████ ', '█    █', '█████ ', '█   █ ', '█    █'];
      case 'S':
        return [' █████', '█     ', ' ████ ', '     █', '█████ '];
      case 'T':
        return ['██████', '  ██  ', '  ██  ', '  ██  ', '  ██  '];
      case 'U':
        return ['█    █', '█    █', '█    █', '█    █', ' █████'];
      case 'V':
        return ['█    █', '█    █', '█    █', ' █  █ ', '  ██  '];
      case 'W':
        return ['█    █', '█    █', '█ ██ █', '██  ██', '█    █'];
      case 'X':
        return ['█    █', ' █  █ ', '  ██  ', ' █  █ ', '█    █'];
      case 'Y':
        return ['█    █', ' █  █ ', '  ██  ', '  ██  ', '  ██  '];
      case 'Z':
        return ['██████', '    █ ', '   █  ', '  █   ', '██████'];

      // Numbers 0-9
      case '0':
        return [' █████', '█   █ ', '█ █ █ ', '█  █ █', ' █████'];
      case '1':
        return ['  ██  ', ' ███  ', '  ██  ', '  ██  ', '██████'];
      case '2':
        return [' █████', '█    █', '   ██ ', '  █   ', '██████'];
      case '3':
        return [' █████', '     █', '  ████', '     █', ' █████'];
      case '4':
        return ['█   █ ', '█   █ ', '██████', '    █ ', '    █ '];
      case '5':
        return ['██████', '█     ', '█████ ', '     █', '█████ '];
      case '6':
        return [' █████', '█     ', '█████ ', '█    █', ' █████'];
      case '7':
        return ['██████', '    █ ', '   █  ', '  █   ', ' █    '];
      case '8':
        return [' █████', '█    █', ' █████', '█    █', ' █████'];
      case '9':
        return [' █████', '█    █', ' ██████', '     █', ' █████'];

      // Common symbols
      case '!':
        return ['  ██  ', '  ██  ', '  ██  ', '      ', '  ██  '];
      case '?':
        return [' █████', '█    █', '   ██ ', '      ', '  ██  '];
      case '.':
        return ['      ', '      ', '      ', '      ', '  ██  '];
      case ',':
        return ['      ', '      ', '      ', '  ██  ', ' █    '];
      case ':':
        return ['      ', '  ██  ', '      ', '  ██  ', '      '];
      case ';':
        return ['      ', '  ██  ', '      ', '  ██  ', ' █    '];
      case '-':
        return ['      ', '      ', '██████', '      ', '      '];
      case '_':
        return ['      ', '      ', '      ', '      ', '██████'];
      case '(':
        return ['   ██ ', '  █   ', '  █   ', '  █   ', '   ██ '];
      case ')':
        return [' ██   ', '   █  ', '   █  ', '   █  ', ' ██   '];
      case '[':
        return ['████  ', '█     ', '█     ', '█     ', '████  '];
      case ']':
        return ['  ████', '     █', '     █', '     █', '  ████'];
      case '/':
        return ['     █', '    █ ', '   █  ', '  █   ', ' █    '];
      case '\\':
        return ['█     ', ' █    ', '  █   ', '   █  ', '    █ '];
      case '+':
        return ['      ', '  ██  ', '██████', '  ██  ', '      '];
      case '=':
        return ['      ', '██████', '      ', '██████', '      '];
      case '*':
        return ['      ', ' █ █ █', '  ███ ', ' █ █ █', '      '];
      case '#':
        return [' █ █  ', '██████', ' █ █  ', '██████', ' █ █  '];
      case '@':
        return [' █████', '█ ███ ', '█ █ █ ', '█ ███ ', ' █████'];
      case '&':
        return [' ███  ', '█   █ ', ' ███  ', '█ █ █ ', ' ███ █'];
      case '%':
        return ['██   █', '██  █ ', '   █  ', '  █ ██', ' █  ██'];
      case r'$':
        return ['  ██  ', ' █████', '██ ██ ', ' █████', '  ██  '];
      case '"':
        return [' █ █  ', ' █ █  ', '      ', '      ', '      '];
      case '\'':
        return ['  ██  ', '  ██  ', '      ', '      ', '      '];
      case '<':
        return ['    █ ', '   █  ', '  █   ', '   █  ', '    █ '];
      case '>':
        return [' █    ', '  █   ', '   █  ', '  █   ', ' █    '];
      case '|':
        return ['  ██  ', '  ██  ', '  ██  ', '  ██  ', '  ██  '];

      // Space
      case ' ':
        return ['      ', '      ', '      ', '      ', '      '];

      // Default fallback for unknown characters
      default:
        return ['██████', '█    █', '█ ?? █', '█    █', '██████'];
    }
  }
}
