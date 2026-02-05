# WCAG 2.1 Implementation Plan for MCI Booking App

## Overview

This document provides a step-by-step implementation guide to achieve WCAG 2.1 AA compliance for the MCI Booking App. The plan is organized by priority and estimated effort.

---

## Phase 1: Critical Issues (Week 1-2)

### 1.1 Add Semantic Labels to All Icons

**Priority:** 🔴 HIGH  
**WCAG Criteria:** 1.1.1 Non-text Content  
**Effort:** 2-3 hours  
**Files to Modify:**
- `lib/Screens/LoginScreen.dart`
- `lib/Screens/HomePage.dart`
- `lib/Screens/BookingsPage.dart`
- `lib/Screens/AdminRoomManagement.dart`
- `lib/Widgets/mybookings/BookingCard.dart`
- `lib/Widgets/home/BookingDetailsCard.dart`

**Implementation Pattern:**

```dart
// BEFORE (Non-compliant)
Icon(Icons.meeting_room, size: 80, color: Theme.of(context).colorScheme.primary)

// AFTER (Compliant)
Icon(
  Icons.meeting_room,
  size: 80,
  color: Theme.of(context).colorScheme.primary,
  semanticLabel: 'Meeting room logo',
)
```

**Common Icons to Update:**

| Icon | Semantic Label |
|------|----------------|
| `Icons.meeting_room` | `'Meeting room'` |
| `Icons.email` | `'Email'` |
| `Icons.lock` | `'Password'` |
| `Icons.visibility` | `'Show password'` |
| `Icons.visibility_off` | `'Hide password'` |
| `Icons.calendar_today` | `'Date'` |
| `Icons.access_time` | `'Time'` |
| `Icons.login` | `'Check in'` |
| `Icons.close` | `'Cancel'` |
| `Icons.check_circle` | `'Confirmed'` |
| `Icons.cancel` | `'Cancelled'` |
| `Icons.verified` | `'Checked in'` |
| `Icons.schedule` | `'Pending'` |
| `Icons.error_outline` | `'Error'` |
| `Icons.refresh` | `'Refresh'` |
| `Icons.edit` | `'Edit'` |
| `Icons.delete` | `'Delete'` |
| `Icons.add` | `'Add'` |
| `Icons.remove` | `'Remove'` |
| `Icons.search` | `'Search'` |
| `Icons.expand_more` | `'Expand'` |
| `Icons.expand_less` | `'Collapse'` |
| `Icons.keyboard_arrow_down` | `'Show more'` |
| `Icons.info_outline` | `'Information'` |
| `Icons.business` | `'Building'` |

---

### 1.2 Add Tooltips to Icon Buttons

**Priority:** 🔴 HIGH  
**WCAG Criteria:** 1.1.1 Non-text Content, 2.1.1 Keyboard  
**Effort:** 1-2 hours  
**Implementation Pattern:**

```dart
// BEFORE
IconButton(
  icon: Icon(Icons.visibility),
  onPressed: () { ... },
)

// AFTER
IconButton(
  icon: Icon(Icons.visibility, semanticLabel: 'Show password'),
  tooltip: 'Show password',
  onPressed: () { ... },
)
```

---

### 1.3 Fix Color Contrast Issues

**Priority:** 🔴 HIGH  
**WCAG Criteria:** 1.4.3 Contrast Minimum, 1.4.11 Non-text Contrast  
**Effort:** 1 hour  
**File:** `lib/Resources/AppColors.dart`

**Changes Required:**

```dart
// BEFORE (Fails contrast - 1.2:1 on white)
static const Color statusYellow = Color(0xFFFFEB3B);

// AFTER (Options)
// Option 1: Darker yellow for light backgrounds
static const Color statusYellow = Color(0xFFF9A825); // 3:1 contrast

// Option 2: Keep yellow but use dark text
// In widgets, ensure text on yellow uses Colors.black87
```

**Update Status Badge Text Colors:**

```dart
// In BookingCard.dart - _buildStatusBadge method
// For yellow/orange badges, use dark text
case BookingStatus.pending:
  backgroundColor = Colors.orange.withOpacity(0.15);
  textColor = Colors.orange.shade900; // Darker for contrast
```

---

## Phase 2: Screen Reader Support (Week 2-3)

### 2.1 Implement Semantics Widgets

**Priority:** 🔴 HIGH  
**WCAG Criteria:** 4.1.2 Name, Role, Value  
**Effort:** 4-6 hours  
**Implementation Pattern:**

```dart
import 'package:flutter/material.dart';

// Custom accessible button wrapper
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onPressed;

  const AccessibleButton({
    required this.child,
    required this.label,
    this.hint,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      enabled: onPressed != null,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

// Accessible card wrapper
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String label;
  final String? value;

  const AccessibleCard({
    required this.child,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      value: value,
      child: Card(child: child),
    );
  }
}
```

**Apply to Key Components:**

1. **Booking Cards** (`BookingCard.dart`):
```dart
Semantics(
  container: true,
  label: 'Booking for $roomName in $buildingName',
  value: '${booking.status.name}, ${_formatDate(booking.startTime)}',
  child: Card(...)
)
```

2. **Check-in Button** (`HomePage.dart`):
```dart
Semantics(
  button: true,
  label: 'Check in to $roomName',
  hint: 'Opens check-in code dialog',
  child: ElevatedButton(...)
)
```

3. **Form Fields** (`BookingDetailsCard.dart`):
```dart
Semantics(
  textField: true,
  label: 'Number of attendees',
  value: _attendees.toString(),
  child: TextField(...)
)
```

---

### 2.2 Add Live Region Announcements

**Priority:** 🟡 MEDIUM  
**WCAG Criteria:** 4.1.3 Status Messages  
**Effort:** 2 hours  

**Create Announcement Helper:**

```dart
// lib/Helper/accessibility_utils.dart
import 'package:flutter/material.dart';

class AccessibilityAnnouncer {
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
}

// Usage in async operations
Future<void> _handleLogin() async {
  // ... login logic
  if (success) {
    AccessibilityAnnouncer.announce(context, 'Login successful, navigating to home');
  } else {
    AccessibilityAnnouncer.announce(context, 'Login failed, please check your credentials');
  }
}
```

**Apply to:**
- Login success/failure
- Booking creation/cancellation
- Check-in success/failure
- Loading states
- Error messages

---

## Phase 3: Keyboard Navigation (Week 3-4)

### 3.1 Calendar Keyboard Support

**Priority:** 🔴 HIGH  
**WCAG Criteria:** 2.1.1 Keyboard  
**Effort:** 6-8 hours  
**File:** `lib/Widgets/calendar/calendar_view.dart`

**Implementation Approach:**

```dart
// Add FocusNode and keyboard handlers
class _CalendarViewState extends State<CalendarView> {
  FocusNode _calendarFocusNode = FocusNode();
  int _focusedRoomIndex = 0;
  int _focusedHour = 8; // Start at 8 AM
  
  @override
  void initState() {
    super.initState();
    _calendarFocusNode.requestFocus();
  }

  Widget _buildKeyboardHandler({required Widget child}) {
    return Focus(
      focusNode: _calendarFocusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              _moveFocus(hours: -1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              _moveFocus(hours: 1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
              _moveFocus(rooms: -1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              _moveFocus(rooms: 1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.enter:
            case LogicalKeyboardKey.space:
              _selectTimeSlot();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.escape:
              _cancelSelection();
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  void _moveFocus({int hours = 0, int rooms = 0}) {
    setState(() {
      _focusedHour = (_focusedHour + hours).clamp(6, 23);
      _focusedRoomIndex = (_focusedRoomIndex + rooms).clamp(0, widget.visibleRooms.length - 1);
    });
    
    // Announce to screen reader
    final room = widget.visibleRooms[_focusedRoomIndex];
    SemanticsService.announce(
      'Room ${room.name}, ${_focusedHour.toString().padLeft(2, '0')}:00',
      TextDirection.ltr,
    );
  }
}
```

**Alternative: Add Time Picker Dialog**

For users who cannot use drag-and-drop:

```dart
// Add button to open accessible time picker
ElevatedButton.icon(
  onPressed: _showAccessibleTimePicker,
  icon: Icon(Icons.access_time, semanticLabel: ''),
  label: Text('Select time manually'),
)

void _showAccessibleTimePicker() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Select Booking Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accessible dropdowns for time selection
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Start Time'),
            items: _generateTimeSlots(),
            onChanged: (value) => setState(() => _selectedStartTime = value),
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'End Time'),
            items: _generateTimeSlots(),
            onChanged: (value) => setState(() => _selectedEndTime = value),
          ),
        ],
      ),
    ),
  );
}
```

---

### 3.2 Focus Management for Dialogs

**Priority:** 🟡 MEDIUM  
**WCAG Criteria:** 2.4.3 Focus Order  
**Effort:** 2 hours  

**Create Accessible Dialog Wrapper:**

```dart
class AccessibleDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const AccessibleDialog({
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Text(title),
        ),
        content: content,
        actions: actions,
      ),
    );
  }
}
```

---

## Phase 4: Text and Layout (Week 4)

### 4.1 Support Text Scaling

**Priority:** 🟡 MEDIUM  
**WCAG Criteria:** 1.4.4 Resize Text  
**Effort:** 3-4 hours  

**Update Text Styles:**

```dart
// BEFORE
Text(
  'Welcome Back',
  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
)

// AFTER
Text(
  'Welcome Back',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
  // Wrap in Flexible or use AutoSizeText for constrained spaces
)

// For constrained areas, use AutoSizeText
AutoSizeText(
  'Room Name',
  style: TextStyle(fontSize: 16),
  maxLines: 2,
  minFontSize: 12,
  overflow: TextOverflow.ellipsis,
)
```

**Test at 200% text scale:**
```bash
flutter run --dart-define=TEXT_SCALE_FACTOR=2.0
```

---

### 4.2 Ensure Responsive Layouts

**Priority:** 🟡 MEDIUM  
**WCAG Criteria:** 1.4.10 Reflow  
**Effort:** 2 hours  

**Verify existing responsive patterns work at 320px width:**
- `BookingDetailsCard` already uses `LayoutBuilder`
- `HomePage` has mobile/desktop layouts
- Test all screens at 320px width

---

## Phase 5: Testing and Validation (Week 5)

### 5.1 Automated Testing

**Add Accessibility Tests:**

```dart
// test/accessibility_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mci_booking_app/main.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('All icons have semantic labels', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Find all icons
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      
      for (final icon in icons) {
        expect(
          icon.semanticLabel,
          isNotNull,
          reason: 'Icon ${icon.icon} should have a semantic label',
        );
      }
    });

    testWidgets('All buttons have tooltips or text', (tester) async {
      await tester.pumpWidget(MyApp());
      
      final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton));
      
      for (final button in iconButtons) {
        expect(
          button.tooltip,
          isNotNull,
          reason: 'IconButton should have a tooltip',
        );
      }
    });
  });
}
```

### 5.2 Manual Testing Checklist

**Screen Reader Testing:**
- [ ] Test with TalkBack (Android)
- [ ] Test with VoiceOver (iOS)
- [ ] Navigate entire app using only screen reader
- [ ] Verify all interactive elements are announced
- [ ] Verify status updates are announced

**Keyboard Testing:**
- [ ] Test with Bluetooth keyboard on device
- [ ] Test with Tab/Shift+Tab navigation
- [ ] Verify Enter/Space activates buttons
- [ ] Verify Escape closes dialogs
- [ ] Test calendar navigation with arrow keys

**Visual Testing:**
- [ ] Test at 200% text scale
- [ ] Test at 320px width
- [ ] Verify color contrast with contrast checker
- [ ] Test in both light and dark modes

---

## Implementation Priority Matrix

| Issue | WCAG Level | Effort | Priority | Phase |
|-------|------------|--------|----------|-------|
| Icon semantic labels | A | Low | 🔴 Critical | 1 |
| Color contrast fixes | AA | Low | 🔴 Critical | 1 |
| Semantics widgets | A | Medium | 🔴 Critical | 2 |
| Calendar keyboard nav | A | High | 🔴 Critical | 3 |
| Tooltip additions | A | Low | 🟡 High | 1 |
| Live region announcements | AA | Low | 🟡 High | 2 |
| Focus management | AA | Medium | 🟡 High | 3 |
| Text scaling support | AA | Medium | 🟢 Medium | 4 |
| Responsive layouts | AA | Low | 🟢 Medium | 4 |
| Automated tests | - | Medium | 🟢 Low | 5 |

---

## Flutter Accessibility Resources

- [Flutter Accessibility Documentation](https://docs.flutter.dev/accessibility)
- [Semantics Widget Guide](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Accessibility Testing](https://docs.flutter.dev/testing/accessibility)

---

## Success Criteria

The app will be considered WCAG 2.1 AA compliant when:

1. ✅ All icons have semantic labels
2. ✅ All non-text content has text alternatives
3. ✅ Color contrast ratios meet 4.5:1 for text, 3:1 for UI components
4. ✅ All functionality is available via keyboard
5. ✅ Screen readers can navigate and announce all content
6. ✅ Text can be resized to 200% without loss of content
7. ✅ Focus is visible and logically ordered
8. ✅ Status messages are announced to screen readers

---

## Maintenance

After initial implementation:

1. **Code Reviews:** Check accessibility in all PRs
2. **Automated Tests:** Run accessibility tests in CI/CD
3. **Regular Audits:** Quarterly accessibility reviews
4. **User Testing:** Include users with disabilities in testing

---

*Last Updated: 2026-02-05*  
*Next Review: After Phase 1 completion*
