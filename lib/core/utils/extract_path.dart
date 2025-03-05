String extractMiddleSegments(String input) {
  // Split the string by '/'
  final segments = input.split('/');
  // Ensure there are at least 3 segments (e.g., "egp/a11/u1/any_integer")
  if (segments.length >= 3) {
    // Return the second and third segments joined by '/'
    return '${segments[1]}/${segments[2]}';
  }
  // If there are fewer than 3 segments, return the original string
  return input;
}

String extractPathFromEgp(String url) {
  const String keyword = "egp";
  int index = url.indexOf(keyword);

  if (index != -1) {
    return url.substring(index); // Keep everything from "egp" onwards
  } else {
    throw Exception("Keyword '$keyword' not found in URL");
  }
}
