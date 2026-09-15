import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';

/// Opens the backend's `GET /metrics/stream` Server-Sent Events endpoint and
/// emits each ingested metric as it arrives.
///
/// The backend has always published this stream;;the dashboard previously
/// ignored it and polled instead, which is why the "Live" badge was showing
/// on data that could be up to a full poll interval stale.
abstract class MetricsStreamDataSource {
  /// Emits one event per metric ingested for [appId].
  ///
  /// The returned stream is single-subscription: the underlying HTTP
  /// connection is opened on listen and closed on cancel.
  Stream<Map<String, dynamic>> watch(String appId);
}

@LazySingleton(as: MetricsStreamDataSource)
class MetricsStreamDataSourceImpl implements MetricsStreamDataSource {
  final DioClient client;

  MetricsStreamDataSourceImpl(this.client);

  @override
  Stream<Map<String, dynamic>> watch(String appId) async* {
    final cancelToken = CancelToken();

    try {
      final response = await client.dio.get<ResponseBody>(
        '/metrics/stream',
        queryParameters: {'appId': appId},
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // The stream is intentionally open-ended, so the client must not
          // time it out the way it would a normal request.
          receiveTimeout: Duration.zero,
        ),
      );

      final body = response.data;
      if (body == null) return;

      // An SSE frame ends at a blank line; a frame can carry several
      // `data:` lines that concatenate into one payload.
      final buffer = StringBuffer();

      final lines = body.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.isEmpty) {
          final payload = buffer.toString();
          buffer.clear();

          if (payload.isEmpty) continue;

          final decoded = _tryDecode(payload);
          if (decoded != null) yield decoded;
          continue;
        }

        // Comment frames (`: ping`, `: connected`) are keep-alives.
        if (line.startsWith(':')) continue;

        if (line.startsWith('data:')) {
          buffer.write(line.substring(5).trimLeft());
        }
      }
    } finally {
      // Covers normal completion, cancellation and errors alike, so the
      // socket is never left open behind a dropped subscription.
      if (!cancelToken.isCancelled) cancelToken.cancel();
    }
  }

  /// A malformed frame must not tear down a long-lived stream.
  static Map<String, dynamic>? _tryDecode(String payload) {
    try {
      final decoded = json.decode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
