class Config {

  static const APP_NAME = "YAP!";
  static const DEFAULT_KEY_TYPE = "rsa";
  static const DEFAULT_KEY_LENGTH = 2048;

  static final keyTypes = {"rsa", "x25519"}.toList();
  static final keyLengths = {2048, 3072, 4096}.toList();
}