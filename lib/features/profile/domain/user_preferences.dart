import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

enum CommunicationMode { signToText, voiceToSign, signToVoice, interpreter }

enum RecognitionMode { onDevice, remote }

enum AccessibilityNeed { deaf, hardOfHearing, speechDifference, lowVision, motor }

class NotificationPrefs extends Equatable {
  const NotificationPrefs({
    this.learningReminders = true,
    this.practiceStreak = true,
    this.trialReminders = true,
    this.renewalInfo = true,
    this.interpreterUpdates = true,
    this.system = true,
  });

  final bool learningReminders;
  final bool practiceStreak;
  final bool trialReminders;
  final bool renewalInfo;
  final bool interpreterUpdates;
  final bool system;

  NotificationPrefs copyWith({
    bool? learningReminders,
    bool? practiceStreak,
    bool? trialReminders,
    bool? renewalInfo,
    bool? interpreterUpdates,
    bool? system,
  }) =>
      NotificationPrefs(
        learningReminders: learningReminders ?? this.learningReminders,
        practiceStreak: practiceStreak ?? this.practiceStreak,
        trialReminders: trialReminders ?? this.trialReminders,
        renewalInfo: renewalInfo ?? this.renewalInfo,
        interpreterUpdates: interpreterUpdates ?? this.interpreterUpdates,
        system: system ?? this.system,
      );

  Map<String, dynamic> toJson() => {
        'learningReminders': learningReminders,
        'practiceStreak': practiceStreak,
        'trialReminders': trialReminders,
        'renewalInfo': renewalInfo,
        'interpreterUpdates': interpreterUpdates,
        'system': system,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const NotificationPrefs();
    bool b(String k) => j[k] as bool? ?? true;
    return NotificationPrefs(
      learningReminders: b('learningReminders'),
      practiceStreak: b('practiceStreak'),
      trialReminders: b('trialReminders'),
      renewalInfo: b('renewalInfo'),
      interpreterUpdates: b('interpreterUpdates'),
      system: b('system'),
    );
  }

  @override
  List<Object?> get props =>
      [learningReminders, practiceStreak, trialReminders, renewalInfo, interpreterUpdates, system];
}

class UserPreferences extends Equatable {
  const UserPreferences({
    this.themeMode = AppThemeMode.system,
    this.localeCode,
    this.textScale = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
    this.haptics = true,
    this.voiceFeedback = false,
    this.preferredMode = CommunicationMode.signToText,
    this.accessibilityNeeds = const {},
    this.ttsRate = 0.5,
    this.ttsLanguage = 'en-IN',
    this.ttsVoiceName,
    this.ttsVoiceLocale,
    this.confidenceThreshold = 0.7,
    this.recognitionMode = RecognitionMode.onDevice,
    this.autoSpeak = false,
    this.mirrorCamera = true,
    this.saveHistory = true,
    this.analyticsEnabled = true,
    this.notifications = const NotificationPrefs(),
    this.reminderHour = 18,
  });

  final AppThemeMode themeMode;

  /// `null` follows the device language.
  final String? localeCode;
  final double textScale;
  final bool highContrast;
  final bool reduceMotion;
  final bool haptics;
  final bool voiceFeedback;
  final CommunicationMode preferredMode;
  final Set<AccessibilityNeed> accessibilityNeeds;
  final double ttsRate;
  final String ttsLanguage;
  final String? ttsVoiceName;
  final String? ttsVoiceLocale;
  final double confidenceThreshold;
  final RecognitionMode recognitionMode;
  final bool autoSpeak;
  final bool mirrorCamera;
  final bool saveHistory;
  final bool analyticsEnabled;
  final NotificationPrefs notifications;
  final int reminderHour;

  UserPreferences copyWith({
    AppThemeMode? themeMode,
    String? localeCode,
    bool clearLocale = false,
    double? textScale,
    bool? highContrast,
    bool? reduceMotion,
    bool? haptics,
    bool? voiceFeedback,
    CommunicationMode? preferredMode,
    Set<AccessibilityNeed>? accessibilityNeeds,
    double? ttsRate,
    String? ttsLanguage,
    String? ttsVoiceName,
    String? ttsVoiceLocale,
    bool clearVoice = false,
    double? confidenceThreshold,
    RecognitionMode? recognitionMode,
    bool? autoSpeak,
    bool? mirrorCamera,
    bool? saveHistory,
    bool? analyticsEnabled,
    NotificationPrefs? notifications,
    int? reminderHour,
  }) =>
      UserPreferences(
        themeMode: themeMode ?? this.themeMode,
        localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
        textScale: textScale ?? this.textScale,
        highContrast: highContrast ?? this.highContrast,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        haptics: haptics ?? this.haptics,
        voiceFeedback: voiceFeedback ?? this.voiceFeedback,
        preferredMode: preferredMode ?? this.preferredMode,
        accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
        ttsRate: ttsRate ?? this.ttsRate,
        ttsLanguage: ttsLanguage ?? this.ttsLanguage,
        ttsVoiceName: clearVoice ? null : (ttsVoiceName ?? this.ttsVoiceName),
        ttsVoiceLocale: clearVoice ? null : (ttsVoiceLocale ?? this.ttsVoiceLocale),
        confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
        recognitionMode: recognitionMode ?? this.recognitionMode,
        autoSpeak: autoSpeak ?? this.autoSpeak,
        mirrorCamera: mirrorCamera ?? this.mirrorCamera,
        saveHistory: saveHistory ?? this.saveHistory,
        analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
        notifications: notifications ?? this.notifications,
        reminderHour: reminderHour ?? this.reminderHour,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'localeCode': localeCode,
        'textScale': textScale,
        'highContrast': highContrast,
        'reduceMotion': reduceMotion,
        'haptics': haptics,
        'voiceFeedback': voiceFeedback,
        'preferredMode': preferredMode.name,
        'accessibilityNeeds': accessibilityNeeds.map((e) => e.name).toList(),
        'ttsRate': ttsRate,
        'ttsLanguage': ttsLanguage,
        'ttsVoiceName': ttsVoiceName,
        'ttsVoiceLocale': ttsVoiceLocale,
        'confidenceThreshold': confidenceThreshold,
        'recognitionMode': recognitionMode.name,
        'autoSpeak': autoSpeak,
        'mirrorCamera': mirrorCamera,
        'saveHistory': saveHistory,
        'analyticsEnabled': analyticsEnabled,
        'notifications': notifications.toJson(),
        'reminderHour': reminderHour,
      };

  /// Tolerant of missing/unknown fields so older stored versions keep loading.
  factory UserPreferences.fromJson(Map<String, dynamic> j) {
    T e<T extends Enum>(List<T> values, Object? name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    const d = UserPreferences();
    return UserPreferences(
      themeMode: e(AppThemeMode.values, j['themeMode'], d.themeMode),
      localeCode: j['localeCode'] as String?,
      textScale: ((j['textScale'] as num?)?.toDouble() ?? d.textScale).clamp(0.85, 1.6),
      highContrast: j['highContrast'] as bool? ?? d.highContrast,
      reduceMotion: j['reduceMotion'] as bool? ?? d.reduceMotion,
      haptics: j['haptics'] as bool? ?? d.haptics,
      voiceFeedback: j['voiceFeedback'] as bool? ?? d.voiceFeedback,
      preferredMode: e(CommunicationMode.values, j['preferredMode'], d.preferredMode),
      accessibilityNeeds: {
        for (final n in (j['accessibilityNeeds'] as List<dynamic>? ?? const []))
          e(AccessibilityNeed.values, n, AccessibilityNeed.deaf),
      },
      ttsRate: ((j['ttsRate'] as num?)?.toDouble() ?? d.ttsRate).clamp(0.1, 1.0),
      ttsLanguage: j['ttsLanguage'] as String? ?? d.ttsLanguage,
      ttsVoiceName: j['ttsVoiceName'] as String?,
      ttsVoiceLocale: j['ttsVoiceLocale'] as String?,
      confidenceThreshold:
          ((j['confidenceThreshold'] as num?)?.toDouble() ?? d.confidenceThreshold).clamp(0.3, 0.95),
      recognitionMode: e(RecognitionMode.values, j['recognitionMode'], d.recognitionMode),
      autoSpeak: j['autoSpeak'] as bool? ?? d.autoSpeak,
      mirrorCamera: j['mirrorCamera'] as bool? ?? d.mirrorCamera,
      saveHistory: j['saveHistory'] as bool? ?? d.saveHistory,
      analyticsEnabled: j['analyticsEnabled'] as bool? ?? d.analyticsEnabled,
      notifications: NotificationPrefs.fromJson(j['notifications'] as Map<String, dynamic>?),
      reminderHour: (j['reminderHour'] as int? ?? d.reminderHour).clamp(0, 23),
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        localeCode,
        textScale,
        highContrast,
        reduceMotion,
        haptics,
        voiceFeedback,
        preferredMode,
        accessibilityNeeds,
        ttsRate,
        ttsLanguage,
        ttsVoiceName,
        ttsVoiceLocale,
        confidenceThreshold,
        recognitionMode,
        autoSpeak,
        mirrorCamera,
        saveHistory,
        analyticsEnabled,
        notifications,
        reminderHour,
      ];
}
