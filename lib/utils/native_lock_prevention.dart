import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// **NATIVE LOCK CONTENTION PREVENTION**
/// 
/// This utility prevents native-level mutex lock contention ANRs by:
/// - Wrapping native operations with timeouts
/// - Moving heavy native operations to background isolates
/// - Monitoring native lock contention
/// - Providing safe wrappers for platform channels
class NativeLockPrevention {
  static const Duration _maxNativeOperationTime = Duration(seconds: 2);
  static const Duration _maxHeavyNativeOperationTime = Duration(seconds: 5);
  static final Map<String, DateTime> _activeNativeOperations = {};
  static Timer? _lockContentionMonitor;
  static bool _isMonitoring = false;
  
  /// **Safe native operation execution**
  /// 
  /// Wraps native operations with timeout and lock contention monitoring
  static Future<T> safeNativeOperation<T>(
    String operationName,
    Future<T> Function() nativeOperation, {
    Duration? timeout,
    bool useIsolate = false,
  }) async {
    final startTime = DateTime.now();
    _activeNativeOperations[operationName] = startTime;
    
    try {
      if (useIsolate) {
        // Move heavy native operations to isolate
        return await _executeInIsolate(operationName, nativeOperation, timeout);
      } else {
        // Execute with timeout
        return await nativeOperation().timeout(
          timeout ?? _maxNativeOperationTime,
          onTimeout: () {
            _reportNativeTimeout(operationName);
            throw TimeoutException('Native operation timed out: $operationName');
          },
        );
      }
    } finally {
      _activeNativeOperations.remove(operationName);
    }
  }
  
  /// **Execute heavy native operations in isolate**
  static Future<T> _executeInIsolate<T>(
    String operationName,
    Future<T> Function() nativeOperation,
    Duration? timeout,
  ) async {
    try {
      return await compute(_executeNativeInIsolate, {
        'operationName': operationName,
        'timeout': timeout?.inMilliseconds,
      });
    } catch (e) {
      _reportNativeIsolateError(operationName, e);
      rethrow;
    }
  }
  
  /// **Execute native operation in isolate**
  static T _executeNativeInIsolate<T>(Map<String, dynamic> params) {
    final operationName = params['operationName'] as String;
    final timeoutMs = params['timeout'] as int?;
    
    // This would be implemented based on specific native operations
    // For now, simulate the operation
    return null as T;
  }
  
  /// **Start monitoring native lock contention**
  static void startLockContentionMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _lockContentionMonitor = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkForLockContention();
    });
    
    log('NATIVE_LOCK_PREVENTION: Started lock contention monitoring');
    FirebaseCrashlytics.instance.log('NATIVE_LOCK_PREVENTION: Started lock contention monitoring');
  }
  
  /// **Stop monitoring native lock contention**
  static void stopLockContentionMonitoring() {
    _lockContentionMonitor?.cancel();
    _lockContentionMonitor = null;
    _isMonitoring = false;
    _activeNativeOperations.clear();
    
    log('NATIVE_LOCK_PREVENTION: Stopped lock contention monitoring');
  }
  
  /// **Check for native lock contention**
  static void _checkForLockContention() {
    final now = DateTime.now();
    
    for (final entry in _activeNativeOperations.entries) {
      final duration = now.difference(entry.value);
      
      if (duration > const Duration(seconds: 3)) {
        _reportNativeLockContention(entry.key, duration);
      }
    }
  }
  
  /// **Report native lock contention**
  static void _reportNativeLockContention(String operationName, Duration duration) {
    final message = 'NATIVE_LOCK_CONTENTION: $operationName blocked for ${duration.inMilliseconds}ms';
    log(message);
    
    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(
      Exception('Native lock contention detected: $operationName'),
      StackTrace.current,
      reason: 'Native operation blocked for ${duration.inMilliseconds}ms',
    );
  }
  
  /// **Report native timeout**
  static void _reportNativeTimeout(String operationName) {
    final message = 'NATIVE_TIMEOUT: $operationName timed out';
    log(message);
    
    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(
      TimeoutException('Native operation timeout: $operationName'),
      StackTrace.current,
      reason: 'Native operation exceeded timeout limit',
    );
  }
  
  /// **Report native isolate error**
  static void _reportNativeIsolateError(String operationName, dynamic error) {
    final message = 'NATIVE_ISOLATE_ERROR: $operationName failed in isolate - $error';
    log(message);
    
    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(
      error,
      StackTrace.current,
      reason: 'Native operation failed in isolate: $operationName',
    );
  }
  
  /// **Get native operation statistics**
  static Map<String, dynamic> getNativeOperationStats() {
    return {
      'activeOperations': _activeNativeOperations.length,
      'activeOperationNames': _activeNativeOperations.keys.toList(),
      'isMonitoring': _isMonitoring,
      'maxOperationTime': _maxNativeOperationTime.inMilliseconds,
      'maxHeavyOperationTime': _maxHeavyNativeOperationTime.inMilliseconds,
    };
  }
  
  /// **Cleanup resources**
  static void cleanup() {
    stopLockContentionMonitoring();
    _activeNativeOperations.clear();
    log('NATIVE_LOCK_PREVENTION: Cleanup completed');
  }
}

/// **PLATFORM CHANNEL ANR PREVENTION**
/// 
/// Prevents ANR in platform channel operations
class PlatformChannelANRPrevention {
  static const Duration _maxChannelTime = Duration(seconds: 1);
  static const Duration _maxHeavyChannelTime = Duration(seconds: 3);
  
  /// **Safe platform channel calls**
  static Future<T> safePlatformCall<T>(
    String methodName,
    dynamic arguments, {
    Duration? timeout,
  }) async {
    return await NativeLockPrevention.safeNativeOperation(
      'PlatformChannel_$methodName',
      () async {
        // This would use actual platform channel calls
        // For now, simulate the operation
        await Future.delayed(const Duration(milliseconds: 100));
        return null as T;
      },
      timeout: timeout ?? _maxChannelTime,
    );
  }
  
  /// **Safe heavy platform channel calls**
  static Future<T> safeHeavyPlatformCall<T>(
    String methodName,
    dynamic arguments, {
    Duration? timeout,
  }) async {
    return await NativeLockPrevention.safeNativeOperation(
      'HeavyPlatformChannel_$methodName',
      () async {
        // Move heavy platform operations to isolate
        return await compute(_executeHeavyPlatformCall, {
          'methodName': methodName,
          'arguments': arguments,
        });
      },
      timeout: timeout ?? _maxHeavyChannelTime,
      useIsolate: true,
    );
  }
  
  /// **Execute heavy platform call in isolate**
  static T _executeHeavyPlatformCall<T>(Map<String, dynamic> params) {
    final methodName = params['methodName'] as String;
    final arguments = params['arguments'];
    
    // This would execute the actual platform call
    // For now, simulate the operation
    return null as T;
  }
}

/// **THIRD-PARTY LIBRARY ANR PREVENTION**
/// 
/// Prevents ANR in third-party native libraries
class ThirdPartyANRPrevention {
  /// **Safe Smartlook operations**
  static Future<void> safeSmartlookOperation(
    String operationName,
    Future<void> Function() smartlookOperation,
  ) async {
    await NativeLockPrevention.safeNativeOperation(
      'Smartlook_$operationName',
      smartlookOperation,
      timeout: const Duration(seconds: 1),
    );
  }
  
  /// **Safe Firebase operations**
  static Future<T> safeFirebaseOperation<T>(
    String operationName,
    Future<T> Function() firebaseOperation,
  ) async {
    return await NativeLockPrevention.safeNativeOperation(
      'Firebase_$operationName',
      firebaseOperation,
      timeout: const Duration(seconds: 2),
    );
  }
  
  /// **Safe Razorpay operations**
  static Future<T> safeRazorpayOperation<T>(
    String operationName,
    Future<T> Function() razorpayOperation,
  ) async {
    return await NativeLockPrevention.safeNativeOperation(
      'Razorpay_$operationName',
      razorpayOperation,
      timeout: const Duration(seconds: 3),
    );
  }
  
  /// **Safe image processing operations**
  static Future<Uint8List> safeImageProcessing(
    String imagePath,
    Map<String, dynamic> options,
  ) async {
    return await NativeLockPrevention.safeNativeOperation(
      'ImageProcessing_$imagePath',
      () async {
        return await compute(_processImageInBackground, {
          'path': imagePath,
          'options': options,
        });
      },
      timeout: const Duration(seconds: 5),
      useIsolate: true,
    );
  }
  
  /// **Process image in background isolate**
  static Uint8List _processImageInBackground(Map<String, dynamic> params) {
    final imagePath = params['path'] as String;
    final options = params['options'] as Map<String, dynamic>;
    
    // This would perform actual image processing
    // For now, return empty bytes
    return Uint8List(0);
  }
}

/// **NATIVE LOCK PREVENTION MIXIN**
/// 
/// Add this mixin to controllers that use native operations
mixin NativeLockPreventionMixin {
  /// **Safe native operation**
  Future<T> safeNativeOperation<T>(
    String operationName,
    Future<T> Function() nativeOperation, {
    Duration? timeout,
    bool useIsolate = false,
  }) async {
    return await NativeLockPrevention.safeNativeOperation(
      operationName,
      nativeOperation,
      timeout: timeout,
      useIsolate: useIsolate,
    );
  }
  
  /// **Safe platform channel call**
  Future<T> safePlatformCall<T>(
    String methodName,
    dynamic arguments, {
    Duration? timeout,
  }) async {
    return await PlatformChannelANRPrevention.safePlatformCall(
      methodName,
      arguments,
      timeout: timeout,
    );
  }
  
  /// **Safe third-party operation**
  Future<T> safeThirdPartyOperation<T>(
    String libraryName,
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    return await NativeLockPrevention.safeNativeOperation(
      '${libraryName}_$operationName',
      operation,
      timeout: timeout,
    );
  }
}
