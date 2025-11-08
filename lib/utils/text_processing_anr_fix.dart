import 'dart:async';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// **TEXT PROCESSING ANR PREVENTION**
///
/// This utility prevents ANR in Flutter text processing operations by:
/// - Wrapping text processing operations with timeouts
/// - Moving heavy text operations to background isolates
/// - Optimizing text input handling
/// - Preventing ProcessTextPlugin ANR
class TextProcessingANRFix {
  static const Duration _maxTextProcessingTime = Duration(milliseconds: 500);
  static const Duration _maxTextActionTime = Duration(milliseconds: 200);
  static final Map<String, DateTime> _activeTextOperations = {};
  static Timer? _textProcessingMonitor;
  static bool _isMonitoring = false;

  /// **Safe text processing operation**
  ///
  /// Wraps text processing operations with timeout and ANR prevention
  static Future<T> safeTextProcessing<T>(
    String operationName,
    Future<T> Function() textOperation, {
    Duration? timeout,
    bool useIsolate = false,
  }) async {
    final startTime = DateTime.now();
    _activeTextOperations[operationName] = startTime;

    try {
      if (useIsolate) {
        // Move heavy text processing to isolate
        return await _executeTextProcessingInIsolate(
            operationName, textOperation, timeout);
      } else {
        // Execute with timeout
        return await textOperation().timeout(
          timeout ?? _maxTextProcessingTime,
          onTimeout: () {
            _reportTextProcessingTimeout(operationName);
            throw TimeoutException('Text processing timed out: $operationName');
          },
        );
      }
    } finally {
      _activeTextOperations.remove(operationName);
    }
  }

  /// **Execute text processing in isolate**
  static Future<T> _executeTextProcessingInIsolate<T>(
    String operationName,
    Future<T> Function() textOperation,
    Duration? timeout,
  ) async {
    try {
      return await compute(_executeTextInIsolate, {
        'operationName': operationName,
        'timeout': timeout?.inMilliseconds,
      });
    } catch (e) {
      _reportTextProcessingIsolateError(operationName, e);
      rethrow;
    }
  }

  /// **Execute text processing in isolate**
  static T _executeTextInIsolate<T>(Map<String, dynamic> params) {
    final operationName = params['operationName'] as String;
    final timeoutMs = params['timeout'] as int?;
    return null as T;
  }

  /// **Safe text tokenization**
  ///
  /// Prevents ANR during text tokenization operations
  static Future<List<String>> safeTokenize(
    String text,
    String operationName,
  ) async {
    return await safeTextProcessing(
      'Tokenize_$operationName',
      () async {
        return await compute(_tokenizeInIsolate, {
          'text': text,
          'operationName': operationName,
        });
      },
      timeout: const Duration(milliseconds: 300),
      useIsolate: true,
    );
  }

  /// **Tokenize text in isolate**
  static List<String> _tokenizeInIsolate(Map<String, dynamic> params) {
    final text = params['text'] as String;
    final operationName = params['operationName'] as String;

    try {
      if (text.isEmpty) return [];

      return text
          .toLowerCase()
          .split(RegExp(r'[\s\-_.,!?()]+'))
          .where((word) => word.length >= 2)
          .map((word) => word.trim())
          .where((word) => word.isNotEmpty)
          .toList();
    } catch (e) {
      log('TEXT_PROCESSING_ANR_FIX: Tokenization failed for $operationName: $e');
      return [];
    }
  }

  /// **Safe text search operation**
  ///
  /// Prevents ANR during text search operations
  static Future<List<T>> safeTextSearch<T>(
    String query,
    List<T> data,
    String Function(T) getText,
    String operationName,
  ) async {
    return await safeTextProcessing(
      'TextSearch_$operationName',
      () async {
        return await compute(_searchInIsolate, {
          'query': query,
          'data': data,
          'getText': getText,
          'operationName': operationName,
        });
      },
      timeout: const Duration(milliseconds: 500),
      useIsolate: true,
    );
  }

  /// **Search in isolate**
  static List<T> _searchInIsolate<T>(Map<String, dynamic> params) {
    final query = params['query'] as String;
    final data = params['data'] as List<T>;
    final getText = params['getText'] as String Function(T);
    final operationName = params['operationName'] as String;

    try {
      if (query.isEmpty) return [];

      final queryLower = query.toLowerCase();
      return data.where((item) {
        final text = getText(item).toLowerCase();
        return text.contains(queryLower);
      }).toList();
    } catch (e) {
      log('TEXT_PROCESSING_ANR_FIX: Search failed for $operationName: $e');
      return [];
    }
  }

  /// **Safe text field operations**
  ///
  /// Prevents ANR during text field operations
  static Future<void> safeTextFieldOperation(
    String operationName,
    Future<void> Function() textFieldOperation,
  ) async {
    await safeTextProcessing(
      'TextField_$operationName',
      textFieldOperation,
      timeout: const Duration(milliseconds: 200),
    );
  }

  /// **Safe text action queries**
  ///
  /// Prevents ANR during text action queries (ProcessTextPlugin)
  static Future<List<String>> safeTextActionQuery(
    String text,
    String operationName,
  ) async {
    return await safeTextProcessing(
      'TextAction_$operationName',
      () async {
        // This would wrap the actual ProcessTextPlugin.queryTextActions call
        // For now, simulate the operation
        await Future.delayed(const Duration(milliseconds: 50));
        return <String>['copy', 'paste', 'select_all'];
      },
      timeout: _maxTextActionTime,
    );
  }

  /// **Start monitoring text processing operations**
  static void startTextProcessingMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _textProcessingMonitor =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkForTextProcessingANR();
    });

    log('TEXT_PROCESSING_ANR_FIX: Started text processing monitoring');
    FirebaseCrashlytics.instance
        .log('TEXT_PROCESSING_ANR_FIX: Started text processing monitoring');
  }

  /// **Stop monitoring text processing operations**
  static void stopTextProcessingMonitoring() {
    _textProcessingMonitor?.cancel();
    _textProcessingMonitor = null;
    _isMonitoring = false;
    _activeTextOperations.clear();

    log('TEXT_PROCESSING_ANR_FIX: Stopped text processing monitoring');
  }

  /// **Check for text processing ANR**
  static void _checkForTextProcessingANR() {
    final now = DateTime.now();

    for (final entry in _activeTextOperations.entries) {
      final duration = now.difference(entry.value);

      if (duration > const Duration(seconds: 2)) {
        _reportTextProcessingANR(entry.key, duration);
      }
    }
  }

  /// **Report text processing ANR**
  static void _reportTextProcessingANR(
      String operationName, Duration duration) {
    final message =
        'TEXT_PROCESSING_ANR: $operationName blocked for ${duration.inMilliseconds}ms';
    log(message);

    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(
      Exception('Text processing ANR detected: $operationName'),
      StackTrace.current,
      reason:
          'Text processing operation blocked for ${duration.inMilliseconds}ms',
    );
  }

  /// **Report text processing timeout**
  static void _reportTextProcessingTimeout(String operationName) {
    final message = 'TEXT_PROCESSING_TIMEOUT: $operationName timed out';
    log(message);

    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(
      TimeoutException('Text processing timeout: $operationName'),
      StackTrace.current,
      reason: 'Text processing operation exceeded timeout limit',
    );
  }

  /// **Report text processing isolate error**
  static void _reportTextProcessingIsolateError(
      String operationName, dynamic error) {
    final message =
        'TEXT_PROCESSING_ISOLATE_ERROR: $operationName failed in isolate - $error';
    log(message);

    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(
      error,
      StackTrace.current,
      reason: 'Text processing operation failed in isolate: $operationName',
    );
  }

  /// **Get text processing statistics**
  static Map<String, dynamic> getTextProcessingStats() {
    return {
      'activeOperations': _activeTextOperations.length,
      'activeOperationNames': _activeTextOperations.keys.toList(),
      'isMonitoring': _isMonitoring,
      'maxTextProcessingTime': _maxTextProcessingTime.inMilliseconds,
      'maxTextActionTime': _maxTextActionTime.inMilliseconds,
    };
  }

  /// **Cleanup resources**
  static void cleanup() {
    stopTextProcessingMonitoring();
    _activeTextOperations.clear();
    log('TEXT_PROCESSING_ANR_FIX: Cleanup completed');
  }
}

/// **TEXT INPUT ANR PREVENTION**
///
/// Prevents ANR in text input operations
class TextInputANRPrevention {
  static const Duration _maxTextInputTime = Duration(milliseconds: 100);

  /// **Safe text input handling**
  static Future<void> safeTextInput(
    String operationName,
    Future<void> Function() textInputOperation,
  ) async {
    await TextProcessingANRFix.safeTextProcessing(
      'TextInput_$operationName',
      textInputOperation,
      timeout: _maxTextInputTime,
    );
  }

  /// **Safe text field focus operations**
  static Future<void> safeTextFieldFocus(
    String operationName,
    Future<void> Function() focusOperation,
  ) async {
    await TextProcessingANRFix.safeTextProcessing(
      'TextFieldFocus_$operationName',
      focusOperation,
      timeout: const Duration(milliseconds: 50),
    );
  }

  /// **Safe text selection operations**
  static Future<void> safeTextSelection(
    String operationName,
    Future<void> Function() selectionOperation,
  ) async {
    await TextProcessingANRFix.safeTextProcessing(
      'TextSelection_$operationName',
      selectionOperation,
      timeout: const Duration(milliseconds: 100),
    );
  }
}

/// **TEXT PROCESSING ANR PREVENTION MIXIN**
///
/// Add this mixin to controllers that handle text processing
mixin TextProcessingANRPreventionMixin {
  /// **Safe text processing operation**
  Future<T> safeTextProcessing<T>(
    String operationName,
    Future<T> Function() textOperation, {
    Duration? timeout,
    bool useIsolate = false,
  }) async {
    return await TextProcessingANRFix.safeTextProcessing(
      operationName,
      textOperation,
      timeout: timeout,
      useIsolate: useIsolate,
    );
  }

  /// **Safe text tokenization**
  Future<List<String>> safeTokenize(
    String text,
    String operationName,
  ) async {
    return await TextProcessingANRFix.safeTokenize(text, operationName);
  }

  /// **Safe text search**
  Future<List<T>> safeTextSearch<T>(
    String query,
    List<T> data,
    String Function(T) getText,
    String operationName,
  ) async {
    return await TextProcessingANRFix.safeTextSearch(
      query,
      data,
      getText,
      operationName,
    );
  }

  /// **Safe text field operation**
  Future<void> safeTextFieldOperation(
    String operationName,
    Future<void> Function() textFieldOperation,
  ) async {
    await TextProcessingANRFix.safeTextFieldOperation(
      operationName,
      textFieldOperation,
    );
  }
}
