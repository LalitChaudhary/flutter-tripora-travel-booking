class Stay {
  const Stay({
    required this.id,
    required this.city,
    required this.name,
    required this.nightMinor,
    required this.roomsLeft,
  });

  final String id;
  final String city;
  final String name;
  final int nightMinor;
  final int roomsLeft;
}

const stays = <Stay>[
  Stay(
      id: 'dune',
      city: 'Lisbon',
      name: 'Dune House',
      nightMinor: 18200,
      roomsLeft: 3),
  Stay(
      id: 'salt',
      city: 'Lisbon',
      name: 'Salt Court',
      nightMinor: 14600,
      roomsLeft: 0),
  Stay(
      id: 'cedar',
      city: 'Kyoto',
      name: 'Cedar Machiya',
      nightMinor: 24000,
      roomsLeft: 2),
];

class BookingQuote {
  const BookingQuote(
      {required this.nights,
      required this.totalMinor,
      required this.available});

  final int nights;
  final int totalMinor;
  final bool available;
}

BookingQuote quoteStay(Stay stay, int nights) {
  final safeNights = nights < 1 ? 1 : nights;
  return BookingQuote(
    nights: safeNights,
    totalMinor: stay.nightMinor * safeNights,
    available: stay.roomsLeft > 0,
  );
}

class TripState {
  const TripState({
    this.signedIn = false,
    this.city = '',
    this.saved = const [],
    this.confirmedId,
    this.error,
  });

  final bool signedIn;
  final String city;
  final List<String> saved;
  final String? confirmedId;
  final String? error;

  List<Stay> get visible => stays.where((stay) {
        final q = city.trim().toLowerCase();
        return q.isEmpty || stay.city.toLowerCase().contains(q);
      }).toList();

  TripState copyWith({
    bool? signedIn,
    String? city,
    List<String>? saved,
    String? confirmedId,
    String? error,
    bool clearError = false,
  }) {
    return TripState(
      signedIn: signedIn ?? this.signedIn,
      city: city ?? this.city,
      saved: saved ?? this.saved,
      confirmedId: confirmedId ?? this.confirmedId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

abstract class TripAction {}

class SignInTrip implements TripAction {
  const SignInTrip(this.email, this.password);
  final String email;
  final String password;
}

class SearchCity implements TripAction {
  const SearchCity(this.city);
  final String city;
}

class SaveStay implements TripAction {
  const SaveStay(this.id);
  final String id;
}

class ConfirmSandbox implements TripAction {
  const ConfirmSandbox(this.id);
  final String id;
}

TripState tripReducer(TripState state, dynamic action) {
  if (action is SignInTrip) {
    final ok = action.email.trim() == 'sena@tripora.dev' &&
        action.password == 'demo1234';
    if (!ok) {
      return state.copyWith(error: 'Use the demo traveler on this screen.');
    }
    return state.copyWith(signedIn: true, clearError: true);
  }
  if (action is SearchCity) {
    return state.copyWith(city: action.city);
  }
  if (action is SaveStay) {
    final ids = [...state.saved];
    if (!ids.contains(action.id)) ids.add(action.id);
    return state.copyWith(saved: ids);
  }
  if (action is ConfirmSandbox) {
    final stay = stays.firstWhere((item) => item.id == action.id);
    if (stay.roomsLeft <= 0) {
      return state.copyWith(error: 'Sample inventory shows no rooms left.');
    }
    return state.copyWith(
      confirmedId: 'TP${action.id}',
      error: 'Sandbox hold only. No reservation was sent to a hotel.',
    );
  }
  return state;
}
