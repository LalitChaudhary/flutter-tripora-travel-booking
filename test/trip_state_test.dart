import 'package:flutter_test/flutter_test.dart';
import 'package:tripora/trip_state.dart';

void main() {
  test('two nights multiply the nightly rate', () {
    final quote = quoteStay(stays.first, 2);
    expect(quote.totalMinor, 36400);
    expect(quote.available, isTrue);
  });

  test('sold out stays cannot be confirmed', () {
    final signed = tripReducer(
        const TripState(), const SignInTrip('sena@tripora.dev', 'demo1234'));
    final next = tripReducer(signed, const ConfirmSandbox('salt'));
    expect(next.confirmedId, isNull);
    expect(next.error, contains('no rooms'));
  });

  test('city filter is case insensitive', () {
    final next =
        tripReducer(const TripState(signedIn: true), const SearchCity('kyo'));
    expect(next.visible.single.id, 'cedar');
  });
}
