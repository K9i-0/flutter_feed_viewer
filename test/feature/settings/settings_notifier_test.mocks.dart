// Mocks generated by Mockito 5.3.2 from annotations
// in flutter_feed_viewer/test/feature/settings/settings_notifier_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:flutter/material.dart' as _i3;
import 'package:flutter_feed_viewer/feature/settings/settings_repository.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [SettingsRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSettingsRepository extends _i1.Mock
    implements _i2.SettingsRepository {
  MockSettingsRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.ThemeMode get themeMode => (super.noSuchMethod(
        Invocation.getter(#themeMode),
        returnValue: _i3.ThemeMode.system,
      ) as _i3.ThemeMode);
  @override
  _i4.Future<void> setThemeMode(_i3.ThemeMode? themeMode) =>
      (super.noSuchMethod(
        Invocation.method(
          #setThemeMode,
          [themeMode],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}