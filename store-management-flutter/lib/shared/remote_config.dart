class RemoteConfig {
  /// Offline/local-only build: no remote host configured.
  static const String? host = null;

  static bool get enabled => host != null && host!.trim().isNotEmpty;
}

