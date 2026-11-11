import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:tripora/main.dart';
import 'package:tripora/trip_state.dart';

void main() {
  testWidgets('traveler sees stays', (tester) async {
    await tester.pumpWidget(
      TriporaApp(
          store:
              Store<TripState>(tripReducer, initialState: const TripState())),
    );
    await tester.tap(find.text('Browse stays'));
    await tester.pumpAndSettle();
    expect(find.text('Dune House'), findsOneWidget);
  });
}
