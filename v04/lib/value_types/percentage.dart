import 'package:equatable/equatable.dart';

class Percentage extends Equatable implements Comparable<Percentage> {
  Percentage(this.value) {
    if (value < 0 || value > 100) {
      throw FormatException(
        "Percentage value must be between 0 and 100, got: $value",
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
