import 'package:flutter/material.dart';

void main() {
  runApp(const SayHello());
}

class SayHello extends StatelessWidget {
  const SayHello({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Say Hello',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SayHelloHomePage(title: 'Say Hello Home Page'),
    );
  }
}

class SayHelloHomePage extends StatefulWidget {
  const SayHelloHomePage({super.key, required this.title});
  final String title;

  @override
  State<SayHelloHomePage> createState() => _SayHelloHomePageState();
}

class _SayHelloHomePageState extends State<SayHelloHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'I have said hello $_counter times',
              style: Theme.of(context).textTheme.headline4,
            ),
            // El botón es difícil de tocar porque está muy cerca de los otros
            // elementos y es muy pequeño
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Say Hello'),
            ),
          ],
        ),
      ),
    );
  }
}
