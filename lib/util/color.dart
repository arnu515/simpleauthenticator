int convertHexStringToNumber(String hex) {
  hex = "FF" + hex.replaceFirst("#", "").toUpperCase();
  return int.parse(hex, radix: 16);
}
