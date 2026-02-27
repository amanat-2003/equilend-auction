// Basic smoke test for the Equilend Auction League app.

import 'package:flutter_test/flutter_test.dart';
import 'package:equilend_auction/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const EquilendAuctionApp());
    // Verify the app title is present in the widget tree.
    expect(find.textContaining('EQUILEND'), findsAny);
  });
}
