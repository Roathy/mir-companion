String truncateAtMircoins(String input) {
  final match = RegExp(r'^(.*?\bmircoins\b)').firstMatch(input);
  return match != null ? match.group(1)! : input;
}
