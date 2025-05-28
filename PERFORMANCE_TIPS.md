# Flutter Performance Optimization Tips

## GPU Buffer Allocation Errors

If you're seeing errors like:
```
E/gralloc4: ERROR: Format allocation info not found for format: 3b  
E/GraphicBufferAllocator: Failed to allocate (4 x 4) layerCount 1 format 59 usage b00: 5  
```

Try these solutions:

1. **Update Flutter**: `flutter upgrade` to get the latest engine version
2. **Shader Precompilation**: Use shader warm-up as implemented in the app
3. **Reduce Image Resolution**: If using high-res images, consider scaling them down
4. **Test on Different Devices**: Some issues are device-specific

## Main Thread Performance Optimization

### 1. Use Isolates for Heavy Computations

We've implemented the `BackgroundWorker` utility class to handle heavy computations in separate isolates:

```dart
// Example usage:
final result = await BackgroundWorker.compute(
  heavyProcessingFunction, 
  inputData
);
```

### 2. Widget Optimization

- Use `const` constructors wherever possible
- Implement `ListView.builder` instead of regular `ListView` for long lists
- Use `RepaintBoundary` to isolate repainting to specific widgets
- Avoid unnecessary rebuilds with `StatefulBuilder` or `ValueNotifier`

### 3. Image Optimization

- Use appropriate image formats (WebP for Android, HEIC for iOS)
- Implement proper caching with `cached_network_image`
- Resize images to their display size before loading

### 4. Animation Optimization

- Use `AnimatedBuilder` with external controllers
- Avoid animations that run continuously
- Use simpler curves for complex animations

### 5. State Management

- Keep widget rebuilds localized
- Use efficient state management solutions (Provider, Riverpod, Bloc)
- Avoid rebuilding the entire widget tree when only a small part needs updating

### 6. Memory Management

- Dispose controllers, animations, and streams
- Use weak references for callbacks to avoid memory leaks
- Profile memory usage with DevTools

## Profiling Tools

1. **Flutter DevTools**: Access via the URL shown in your console logs
2. **Performance Overlay**: Enable with `MaterialApp(showPerformanceOverlay: true)`
3. **Timeline Events**: Use `Timeline.startSync()` and `Timeline.finishSync()`

## Specific Recommendations for This App

1. Implement caching for Firebase data
2. Use pagination for lists of courses and consultations
3. Lazy load images and content that's not immediately visible
4. Consider using a more efficient state management solution as the app grows 