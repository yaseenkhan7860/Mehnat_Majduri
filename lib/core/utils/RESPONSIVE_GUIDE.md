# Responsive Design Guide

This guide explains how to use the responsive utilities in the Astro app.

## ScreenUtil Setup

The app uses `flutter_screenutil` for responsive sizing. It's initialized in the `App` class with a design size of 375x812 (iPhone X).

```dart
ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) {
    return MaterialApp(...);
  },
)
```

## Extension Methods

### Basic Extensions

Use these extension methods to make your UI responsive:

- `.w` - Responsive width (based on design width)
- `.h` - Responsive height (based on design height)
- `.sp` - Responsive font size
- `.r` - Responsive radius

Example:
```dart
Container(
  width: 100.w,
  height: 50.h,
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

### Widget Extensions

These extension methods allow you to add responsive padding and margin to widgets:

- `.paddingAll(value)` - Add padding on all sides
- `.paddingSymmetric(horizontal: value, vertical: value)` - Add symmetric padding
- `.paddingOnly(left: value, top: value, right: value, bottom: value)` - Add specific padding
- `.marginAll(value)` - Add margin on all sides
- `.marginSymmetric(horizontal: value, vertical: value)` - Add symmetric margin
- `.marginOnly(left: value, top: value, right: value, bottom: value)` - Add specific margin

Example:
```dart
Text('Hello')
  .paddingAll(16)
  .marginSymmetric(vertical: 8)
```

## AppSizes

Use the `AppSizes` class for consistent sizing throughout the app:

### Font Sizes
- `AppSizes.fontXS` - 10.sp
- `AppSizes.fontS` - 12.sp
- `AppSizes.fontM` - 14.sp
- `AppSizes.fontL` - 16.sp
- `AppSizes.fontXL` - 18.sp
- `AppSizes.font2XL` - 20.sp
- `AppSizes.font3XL` - 24.sp
- `AppSizes.font4XL` - 32.sp

### Icon Sizes
- `AppSizes.iconXS` - 16.sp
- `AppSizes.iconS` - 20.sp
- `AppSizes.iconM` - 24.sp
- `AppSizes.iconL` - 32.sp
- `AppSizes.iconXL` - 40.sp

### Spacing
- `AppSizes.spacingXS` - 4.w
- `AppSizes.spacingS` - 8.w
- `AppSizes.spacingM` - 16.w
- `AppSizes.spacingL` - 24.w
- `AppSizes.spacingXL` - 32.w
- `AppSizes.spacing2XL` - 40.w
- `AppSizes.spacing3XL` - 48.w

### Border Radius
- `AppSizes.borderRadiusXS` - 4.r
- `AppSizes.borderRadiusS` - 8.r
- `AppSizes.borderRadiusM` - 12.r
- `AppSizes.borderRadiusL` - 16.r
- `AppSizes.borderRadiusXL` - 24.r
- `AppSizes.borderRadius2XL` - 32.r

### Other Sizes
- Button heights: `buttonHeightS`, `buttonHeightM`, `buttonHeightL`, `buttonHeightXL`
- Input heights: `inputHeightS`, `inputHeightM`, `inputHeightL`, `inputHeightXL`
- Avatar sizes: `avatarXS`, `avatarS`, `avatarM`, `avatarL`, `avatarXL`, `avatar2XL`
- Card padding: `cardPaddingS`, `cardPaddingM`, `cardPaddingL`
- Screen padding: `screenPadding`, `screenPaddingHorizontal`, `screenPaddingVertical`
- Navigation: `bottomNavHeight`, `bottomNavWithPaddingHeight`, `appBarHeight`
- Divider: `dividerHeight`, `dividerThickness`

## Best Practices

1. **Always use responsive sizing** for UI elements to ensure they look good on all devices.
2. **Use AppSizes** for consistent sizing throughout the app.
3. **Use extension methods** for cleaner code.
4. **Test on multiple devices** to ensure your UI looks good on different screen sizes.
5. **Consider orientation changes** and adjust your UI accordingly. 