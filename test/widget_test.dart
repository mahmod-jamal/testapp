import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elevator_simulator/main.dart';

void main() {
  testWidgets('shows elevator status and travels to a selected floor', (
    tester,
  ) async {
    await tester.pumpWidget(const ElevatorApp());

    expect(find.text('1'), findsWidgets);
    expect(find.text('DOORS CLOSED'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('floor-3')));
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.text('3'), findsWidgets);
    expect(find.text('DOORS OPEN'), findsOneWidget);
  });

  testWidgets('door controls open and close the elevator doors', (
    tester,
  ) async {
    await tester.pumpWidget(const ElevatorApp());

    await tester.ensureVisible(find.text('OPEN DOOR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OPEN DOOR'));
    await tester.pump();
    expect(find.text('DOORS OPEN'), findsOneWidget);

    await tester.tap(find.text('CLOSE DOOR'));
    await tester.pump();
    expect(find.text('DOORS CLOSED'), findsOneWidget);
  });
}
