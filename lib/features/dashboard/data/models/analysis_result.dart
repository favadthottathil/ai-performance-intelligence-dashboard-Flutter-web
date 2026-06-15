/// AI-generated performance analysis for an app, as returned by
/// `GET /metrics/analyze`.
class AnalysisResult {
  final String severity;
  final List<String> issues;
  final List<String> recommendations;
  final String? message;

  AnalysisResult({
    required this.severity,
    required this.issues,
    required this.recommendations,
    this.message,
  });

  /// Default analysis used while no metrics have been collected yet.
  factory AnalysisResult.empty() =>
      AnalysisResult(severity: 'low', issues: [], recommendations: []);

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      severity: json['severity']?.toString() ?? 'low',
      issues: _parseStringList(json['insights'] ?? json['issues']),
      recommendations: _parseStringList(json['recommendations']),
      message: json['message']?.toString(),
    );
  }

  static List<String> _parseStringList(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) {
          if (e is String) return e;
          if (e is Map) {
            final screen = e['screen']?.toString().trim() ?? '';
            final body =
                (e['message']?.toString() ??
                        e['description']?.toString() ??
                        e['suggestion']?.toString() ??
                        e['action']?.toString() ??
                        e['text']?.toString() ??
                        '')
                    .trim();

            if (screen.isNotEmpty && body.isNotEmpty) {
              return '$screen: $body';
            } else if (body.isNotEmpty) {
              return body;
            } else if (screen.isNotEmpty) {
              return screen;
            }
            return e.values
                .where((v) => v != null)
                .map((v) => v.toString().trim())
                .where((s) => s.isNotEmpty)
                .join(' — ');
          }
          return e.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
