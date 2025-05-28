import 'dart:isolate';
import 'package:flutter/foundation.dart' as flutter_foundation;

/// A utility class to handle heavy computations in background isolates
class BackgroundWorker {
  /// Run a heavy computation in a background isolate
  /// 
  /// [computation] is the function to run in the background
  /// [input] is the input data for the computation
  /// Returns the result of the computation
  static Future<R> compute<Q, R>(flutter_foundation.ComputeCallback<Q, R> computation, Q input) {
    return flutter_foundation.compute(computation, input);
  }
  
  /// Example of a heavy computation that should be run in the background
  /// 
  /// [data] is the input data for the computation
  /// Returns the processed data
  static List<int> heavyProcessing(List<int> data) {
    // Simulate a heavy computation
    List<int> result = [];
    for (int i = 0; i < data.length; i++) {
      // Some CPU-intensive operation
      int processedValue = 0;
      for (int j = 0; j < 10000; j++) {
        processedValue += (data[i] * j) % 100;
      }
      result.add(processedValue);
    }
    return result;
  }
}

/// Example usage:
/// ```dart
/// // In your widget or service:
/// final List<int> inputData = [1, 2, 3, 4, 5];
/// final result = await BackgroundWorker.compute(
///   BackgroundWorker.heavyProcessing, 
///   inputData
/// );
/// ``` 