import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../repositories/firebase/collection_repository.dart';
import '../../repositories/firebase/expense_repository.dart';
import '../../repositories/firebase/member_repository.dart';
import '../../repositories/firebase/payment_repository.dart';

// ── SharedPreferences ─────────────────────────────────────────────────────────

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPrefsProvider in main()');
});

// ── Repository providers ──────────────────────────────────────────────────────

final memberRepositoryProvider =
    Provider<MemberRepository>((_) => MemberRepository());

final collectionRepositoryProvider =
    Provider<CollectionRepository>((_) => CollectionRepository());

final paymentRepositoryProvider =
    Provider<PaymentRepository>((_) => PaymentRepository());

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((_) => ExpenseRepository());

// ── Theme ─────────────────────────────────────────────────────────────────────

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  ThemeNotifier(this._prefs)
      : super(_parse(_prefs.getString(AppConstants.keyTheme)));

  static ThemeMode _parse(String? v) => switch (v) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  void set(ThemeMode m) {
    state = m;
    _prefs.setString(AppConstants.keyTheme, m.name);
  }
}
