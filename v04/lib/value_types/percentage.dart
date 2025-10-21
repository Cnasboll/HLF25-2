import 'package:equatable/equatable.dart';
import 'package:v04/amendable/parsing_context.dart';

class Percentage extends Equatable implements Comparable<Percentage> {
  Percentage(this.value, {ParsingContext? parsingContext}) {
    if (value < 0 || value > 100) {
      var context = parsingContext != null
            ? 'When ${parsingContext.toString()}: '
            : '';
      throw FormatException(
        "${context}Percentage value must be within the range 0 to 100, inclusive, got: $value",
      );
    }
  }

  @override
  List<Object?> get props => [value];

  @override
  int compareTo(Percentage other) {
    return value.compareTo(other.value);
  }

  final int value;
}
