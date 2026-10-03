class Dbg {
  static void log({
    required String runId,
    required String hypothesisId,
    required String location,
    required String message,
    Map<String, dynamic>? data,
  }) {
    // Console-only logging: device apps can't write to the project folder.
    // Do not log secrets/PII.
    // ignore: avoid_print
    print('[DBG a5d05b][$runId][$hypothesisId] $location $message '
        '${data ?? const {}}');
  }
}

