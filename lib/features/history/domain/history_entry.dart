import 'package:equatable/equatable.dart';

enum HistoryInputType { signToText, signToVoice, voiceToSign }

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.inputType,
    required this.glosses,
    required this.text,
    required this.timestamp,
    required this.languageCode,
    required this.durationMs,
  });

  final String id;
  final HistoryInputType inputType;

  /// Recognised signs (gloss tokens) or, for voice→sign, the mapped words.
  final List<String> glosses;
  final String text;
  final DateTime timestamp;
  final String languageCode;
  final int durationMs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'inputType': inputType.name,
        'glosses': glosses,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'languageCode': languageCode,
        'durationMs': durationMs,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        id: j['id'] as String,
        inputType: HistoryInputType.values.firstWhere((t) => t.name == j['inputType'], orElse: () => HistoryInputType.signToText),
        glosses: (j['glosses'] as List<dynamic>? ?? const []).cast<String>(),
        text: j['text'] as String? ?? '',
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        languageCode: j['languageCode'] as String? ?? 'en',
        durationMs: j['durationMs'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, inputType, glosses, text, timestamp, languageCode, durationMs];
}
