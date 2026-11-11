import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'trip_state.dart';

void main() {
  runApp(TriporaApp(
      store: Store<TripState>(tripReducer, initialState: const TripState())));
}

class TriporaApp extends StatelessWidget {
  const TriporaApp({super.key, required this.store});

  final Store<TripState> store;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<TripState>(
      store: store,
      child: MaterialApp(
        title: 'Tripora',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B6CA8),
            primary: const Color(0xFF1B6CA8),
            secondary: const Color(0xFFE6D3B3),
            background: Colors.white,
          ),
        ),
        home: const TravelGate(),
      ),
    );
  }
}

class TravelGate extends StatelessWidget {
  const TravelGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<TripState, bool>(
      converter: (store) => store.state.signedIn,
      builder: (context, signedIn) =>
          signedIn ? const StaysPage() : const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController(text: 'sena@tripora.dev');
  final _password = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<TripState, String?>(
      converter: (store) => store.state.error,
      builder: (context, error) {
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Tripora',
                    style: Theme.of(context).textTheme.headlineMedium),
                const Text(
                    'Hotel search uses mock inventory. Confirming does not book a real room.'),
                const SizedBox(height: 16),
                TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email')),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (error != null) Text(error),
                FilledButton(
                  onPressed: () => StoreProvider.of<TripState>(context)
                      .dispatch(SignInTrip(_email.text, _password.text)),
                  child: const Text('Browse stays'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StaysPage extends StatelessWidget {
  const StaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<TripState, TripState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Stays')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'City'),
                onChanged: (value) => StoreProvider.of<TripState>(context)
                    .dispatch(SearchCity(value)),
              ),
              if (state.visible.isEmpty)
                const Text('No stays match that city.'),
              for (final stay in state.visible)
                ListTile(
                  title: Text(stay.name),
                  subtitle: Text(
                    '${stay.city} · \$${(quoteStay(stay, 2).totalMinor / 100).toStringAsFixed(2)} for 2 nights'
                    '${stay.roomsLeft == 0 ? ' · sold out in sample data' : ''}',
                  ),
                  trailing: TextButton(
                    onPressed: () => StoreProvider.of<TripState>(context)
                        .dispatch(ConfirmSandbox(stay.id)),
                    child: const Text('Hold'),
                  ),
                ),
              if (state.confirmedId != null)
                Text('Reference ${state.confirmedId}'),
              if (state.error != null) Text(state.error!),
            ],
          ),
        );
      },
    );
  }
}
