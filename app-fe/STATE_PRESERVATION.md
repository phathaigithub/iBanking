# State Preservation Implementation

## Overview
The Flutter app now preserves state across bottom navigation tab switches using several techniques:

## Implementation Details

### 1. IndexedStack instead of PageView
- **Before**: Used `PageView` which destroys and recreates widgets when navigating
- **After**: Used `IndexedStack` which keeps all widgets in memory but only shows the active one

### 2. AutomaticKeepAliveClientMixin
Added to all three main views:
- `PaymentView`
- `TuitionLookupView` 
- `AccountInfoView`

This mixin prevents the widget tree from being disposed when not visible.

### 3. PageStorageKey
Added unique keys to each view:
- `PageStorageKey('payment_view')`
- `PageStorageKey('tuition_lookup_view')`
- `PageStorageKey('account_info_view')`

### 4. Late Widget Initialization
Widgets are initialized once in `initState()` and reused:

```dart
late final List<Widget> _pages;

@override
void initState() {
  super.initState();
  _pages = [
    const PaymentView(key: PageStorageKey('payment_view')),
    const TuitionLookupView(key: PageStorageKey('tuition_lookup_view'), initiallyShowMyTuition: true),
    const AccountInfoView(key: PageStorageKey('account_info_view')),
  ];
}
```

## Benefits

1. **Form Data Preservation**: If user fills out payment form partially and switches tabs, data remains
2. **Network Request Caching**: API calls don't repeat unnecessarily
3. **UI State Maintenance**: Scroll positions, expanded sections, etc. are preserved
4. **Better Performance**: Reduces widget rebuilding
5. **Better UX**: Instant tab switching without loading states

## Usage

Users can now:
- Start filling payment form → switch to "Tra cứu" → return to payment with data intact
- View tuition fees → switch tabs → return without re-fetching data
- Navigate between tabs seamlessly without losing any work

## Technical Notes

- `super.build(context)` must be called in build method when using `AutomaticKeepAliveClientMixin`
- `wantKeepAlive = true` tells Flutter to preserve the widget state
- `IndexedStack` shows only one child at a time but keeps all in memory
- Memory usage is slightly higher but provides much better UX
