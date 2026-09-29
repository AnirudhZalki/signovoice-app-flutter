import 'package:equatable/equatable.dart';

import '../../../core/utils/date_utils.dart';

enum LearningBadge { firstSign, tenSigns, firstCorrect, tenCorrect, streak3, streak7 }

class PracticeSession extends Equatable {
  const PracticeSession({
    required this.id,
    required this.signId,
    required this.recognized,
    required this.confidence,
    required this.correct,
    required this.timestamp,
  });

  final String id;
  final String signId;
  final String? recognized;
  final double confidence;
  final bool correct;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'signId': signId,
        'recognized': recognized,
        'confidence': confidence,
        'correct': correct,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PracticeSession.fromJson(Map<String, dynamic> j) => PracticeSession(
        id: j['id'] as String,
        signId: j['signId'] as String,
        recognized: j['recognized'] as String?,
        confidence: (j['confidence'] as num?)?.toDouble() ?? 0,
        correct: j['correct'] as bool? ?? false,
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      );

  @override
  List<Object?> get props => [id, signId, recognized, confidence, correct, timestamp];
}

/// Everything about a person's learning: learned signs, bookmarks, XP, streak,
/// badges and a small per-day activity log. Stored locally (small JSON).
class LearningProgress extends Equatable {
  const LearningProgress({
    this.learned = const {},
    this.bookmarked = const {},
    this.xp = 0,
    this.streakDays = 0,
    this.lastActiveDay,
    this.badges = const {},
    this.practiceAttempts = 0,
    this.practiceCorrect = 0,
    this.correctBySign = const {},
    this.activity = const {},
  });

  final Set<String> learned;
  final Set<String> bookmarked;
  final int xp;
  final int streakDays;

  /// `yyyy-mm-dd` of the last day with learning activity.
  final String? lastActiveDay;
  final Set<LearningBadge> badges;
  final int practiceAttempts;
  final int practiceCorrect;
  final Map<String, int> correctBySign;

  /// dayKey -> number of learning actions (last ~60 days kept).
  final Map<String, int> activity;

  double get accuracy => practiceAttempts == 0 ? 0 : practiceCorrect / practiceAttempts;

  LearningProgress copyWith({
    Set<String>? learned,
    Set<String>? bookmarked,
    int? xp,
    int? streakDays,
    String? lastActiveDay,
    Set<LearningBadge>? badges,
    int? practiceAttempts,
    int? practiceCorrect,
    Map<String, int>? correctBySign,
    Map<String, int>? activity,
  }) =>
      LearningProgress(
        learned: learned ?? this.learned,
        bookmarked: bookmarked ?? this.bookmarked,
        xp: xp ?? this.xp,
        streakDays: streakDays ?? this.streakDays,
        lastActiveDay: lastActiveDay ?? this.lastActiveDay,
        badges: badges ?? this.badges,
        practiceAttempts: practiceAttempts ?? this.practiceAttempts,
        practiceCorrect: practiceCorrect ?? this.practiceCorrect,
        correctBySign: correctBySign ?? this.correctBySign,
        activity: activity ?? this.activity,
      );

  Map<String, dynamic> toJson() => {
        'learned': learned.toList(),
        'bookmarked': bookmarked.toList(),
        'xp': xp,
        'streakDays': streakDays,
        'lastActiveDay': lastActiveDay,
        'badges': badges.map((b) => b.name).toList(),
        'practiceAttempts': practiceAttempts,
        'practiceCorrect': practiceCorrect,
        'correctBySign': correctBySign,
        'activity': activity,
      };

  factory LearningProgress.fromJson(Map<String, dynamic> j) => LearningProgress(
        learned: {...(j['learned'] as List<dynamic>? ?? const []).cast<String>()},
        bookmarked: {...(j['bookmarked'] as List<dynamic>? ?? const []).cast<String>()},
        xp: j['xp'] as int? ?? 0,
        streakDays: j['streakDays'] as int? ?? 0,
        lastActiveDay: j['lastActiveDay'] as String?,
        badges: {
          for (final n in (j['badges'] as List<dynamic>? ?? const []))
            for (final b in LearningBadge.values)
              if (b.name == n) b,
        },
        practiceAttempts: j['practiceAttempts'] as int? ?? 0,
        practiceCorrect: j['practiceCorrect'] as int? ?? 0,
        correctBySign: {...((j['correctBySign'] as Map<String, dynamic>?) ?? const {}).map((k, v) => MapEntry(k, v as int))},
        activity: {...((j['activity'] as Map<String, dynamic>?) ?? const {}).map((k, v) => MapEntry(k, v as int))},
      );

  @override
  List<Object?> get props =>
      [learned, bookmarked, xp, streakDays, lastActiveDay, badges, practiceAttempts, practiceCorrect, correctBySign, activity];
}

/// Pure gamification rules — kept deliberately light and educational.
class ProgressRules {
  const ProgressRules._();

  static const xpPerLearnedSign = 5;
  static const xpPerCorrectPractice = 10;
  static const xpPerAttempt = 2;
  static const keepDays = 60;

  /// Marks activity today and updates the streak.
  static LearningProgress touchDay(LearningProgress p, DateTime now) {
    final today = dayKey(now);
    if (p.lastActiveDay == today) {
      return p.copyWith(activity: {...p.activity, today: (p.activity[today] ?? 0) + 1});
    }
    final yesterday = dayKey(dayOnly(now).subtract(const Duration(days: 1)));
    final streak = p.lastActiveDay == yesterday ? p.streakDays + 1 : 1;
    final cutoff = dayKey(dayOnly(now).subtract(const Duration(days: keepDays)));
    final activity = {
      for (final e in p.activity.entries)
        if (e.key.compareTo(cutoff) >= 0) e.key: e.value,
      today: 1,
    };
    return p.copyWith(streakDays: streak, lastActiveDay: today, activity: activity);
  }

  static Set<LearningBadge> evaluateBadges(LearningProgress p) => {
        ...p.badges,
        if (p.learned.isNotEmpty) LearningBadge.firstSign,
        if (p.learned.length >= 10) LearningBadge.tenSigns,
        if (p.practiceCorrect >= 1) LearningBadge.firstCorrect,
        if (p.practiceCorrect >= 10) LearningBadge.tenCorrect,
        if (p.streakDays >= 3) LearningBadge.streak3,
        if (p.streakDays >= 7) LearningBadge.streak7,
      };

  static LearningProgress markLearned(LearningProgress p, String signId, DateTime now) {
    if (p.learned.contains(signId)) return p;
    var n = touchDay(p.copyWith(learned: {...p.learned, signId}, xp: p.xp + xpPerLearnedSign), now);
    n = n.copyWith(badges: evaluateBadges(n));
    return n;
  }

  static LearningProgress recordPractice(LearningProgress p, {required String signId, required bool correct, required DateTime now}) {
    var n = touchDay(p, now).copyWith(
      practiceAttempts: p.practiceAttempts + 1,
      practiceCorrect: p.practiceCorrect + (correct ? 1 : 0),
      xp: p.xp + xpPerAttempt + (correct ? xpPerCorrectPractice : 0),
      correctBySign: correct ? {...p.correctBySign, signId: (p.correctBySign[signId] ?? 0) + 1} : null,
    );
    n = n.copyWith(badges: evaluateBadges(n));
    return n;
  }

  static LearningProgress toggleBookmark(LearningProgress p, String signId) {
    final b = {...p.bookmarked};
    b.contains(signId) ? b.remove(signId) : b.add(signId);
    return p.copyWith(bookmarked: b);
  }

  /// Level from XP: every 100 XP is a level (1-based).
  static int level(int xp) => xp ~/ 100 + 1;
}
