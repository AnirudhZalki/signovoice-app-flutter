import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';

/// Rupees for UI from paise ("₹150", "₹75.50"). Zero reads as the localized word for free.
String formatPaise(AppLocalizations l, int paise) {
  if (paise <= 0) return l.priceFree;
  final f = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: paise % 100 == 0 ? 0 : 2);
  return f.format(paise / 100);
}

String formatPaiseRaw(int paise) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: paise % 100 == 0 ? 0 : 2).format(paise / 100);
