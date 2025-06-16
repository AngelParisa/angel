class Version {
  static const String version = '1.0.11';
  static const String buildSignature = '0x1a2b3c4d'; // Example hex signature
  static const String buildDate = '2024-03-14';

  static String get fullVersion => 'v$version ($buildSignature)';
}
