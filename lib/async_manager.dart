import 'package:async/async.dart';
import 'package:get/get.dart';

enum MultipleCallsBehavior {
  abortNew,
  abortOld,
}

class AsyncOperationStatus<T> {
  bool _isLoading = false;
  T? value;
  Object? _error;

  AsyncOperationStatus({
    this.value,
  });

  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get hasError => _error != null;
  bool get hasValue => value != null;
  bool get isStable => !_isLoading && _error == null;

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(Object? e) {
    _error = e;
  }
}

class AsyncManager<T> extends Rx<AsyncOperationStatus<T>> {
  final bool enableLogging;

  CancelableOperation<T>? _cancelableOperation;

  AsyncManager({T? initialData, this.enableLogging = false})
      : super(AsyncOperationStatus(value: initialData)) {
    _log("AsyncManager initialized with persistent data.");
  }

  T? get data => value.value;

  Object? get error => value.error;

  bool get isLoading => value.isLoading;

  bool get hasError => value.hasError;

  bool get isStable => !isLoading && error != null;

  void _update({bool? loading, T? data, Object? error}) {
    update((val) {
      if (val != null) {
        if (loading != null) val.setLoading(loading);
        if (data != null) val.value = data;
        val.setError(error);
      }
    });
  }

  void setData(T data) {
    _update(data: data);
    _log("Data has been manually updated.");
  }

  T? getData() {
    if (data != null) {
      _log("Returning data.");
      return data;
    }
    return null;
  }

  Future<void> observeAsync({
    required Future<T> Function(T? previousResult) task,
    void Function()? onStart,
    void Function(T)? onSuccess,
    void Function(Object)? onError,
    void Function()? onCancel,
    void Function()? onMultipleCalls,
    MultipleCallsBehavior multipleCallsBehavior =
        MultipleCallsBehavior.abortNew,
    Duration? debounceDuration,
    int maxRetryAttempts = 0,
    Duration retryDelay = const Duration(seconds: 1),
    bool useExponentialBackoff = false,
    Duration? timeout,
  }) async {
    if (debounceDuration != null) {
      await Future.delayed(debounceDuration);
    }
    onStart?.call();

    if (isLoading) {
      onMultipleCalls?.call();
      if (multipleCallsBehavior == MultipleCallsBehavior.abortNew) {
        return;
      } else {
        cancelOperation();
      }
    }

    int attempt = 0;
    Duration currentRetryDelay = retryDelay;
    while (true) {
      try {
        _update(loading: true, error: null);
        Future<T> taskFuture = task(data);
        if (timeout != null) {
          taskFuture = taskFuture.timeout(timeout);
        }
        _cancelableOperation = CancelableOperation<T>.fromFuture(
          taskFuture,
          onCancel: () {
            onCancel?.call();
            _update(loading: false, error: null);
          },
        );
        final T result = await _cancelableOperation!.value;
        _update(data: result, loading: false, error: null);
        onSuccess?.call(result);
        _log("observeAsync completed successfully.");
        break;
      } catch (e) {
        attempt++;
        if (attempt > maxRetryAttempts) {
          _update(loading: false, error: e);
          onError?.call(e);
          _log("observeAsync failed after $attempt attempts: $e");
          break;
        } else {
          _log(
              "Attempt $attempt failed, retrying after ${currentRetryDelay.inSeconds} seconds...");
          await Future.delayed(currentRetryDelay);
          if (useExponentialBackoff) {
            currentRetryDelay *= 2;
          }
        }
      }
    }
  }

  void cancelOperation() {
    _cancelableOperation?.cancel();
    _log("Operation cancelled.");
  }

  void reset() {
    value = AsyncOperationStatus<T>();
    _log("State reset.");
  }

  void cancelAllOperations() {
    _cancelableOperation?.cancel();
    _log("All operations cancelled.");
  }

  void _log(String message) {
    if (enableLogging) {
      Get.log("[AsyncManager] $message");
    }
  }
}
