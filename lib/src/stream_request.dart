import 'dart:async';

import 'package:http/http.dart' as http;

typedef void ProgressCallback(int uploadedBytes, int totalBytes);

class DosSpaceStreamRequest extends http.StreamedRequest {
  final int progressContentLength;
  final ProgressCallback? onProgress;
  DosSpaceStreamRequest(
    String method,
    Uri url, {
    this.onProgress,
    required this.progressContentLength,
  }) : super(method, url);

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final total = progressContentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress!(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
