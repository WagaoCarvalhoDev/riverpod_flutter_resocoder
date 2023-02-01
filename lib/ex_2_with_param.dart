import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WebSocketClient {
  Stream<int> getCounterStream([int start]);
}

class FakeWebSocketClient implements WebSocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    int i = start;
    while (true) {
      yield i++;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}

final webSocketClientProvider =
Provider<WebSocketClient>((ref) => FakeWebSocketClient());

final counterProvider =
StreamProvider.autoDispose.family<int, int>((ref, start) {
  final wsClient = ref.watch(webSocketClientProvider);
  return wsClient.getCounterStream(start);
});

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
          surface: const Color(0xffC36506),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to counter page'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CounterPage(),
            ));
          },
        ),
      ),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('data')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final AsyncValue<int> counter = ref.watch(counterProvider(5));
                return Text(
                  counter
                      .when(
                    data: (value) => value,
                    error: (Object e, s) => e,
                    loading: () => 0,
                  )
                      .toString(),
                  style: Theme
                      .of(context)
                      .textTheme
                      .displayMedium,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
