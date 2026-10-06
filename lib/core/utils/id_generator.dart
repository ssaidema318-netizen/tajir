class IdGenerator {
  static String generate() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}