import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;


// 😉 😉, :nudge: :nudge:
typedef LoadDataFunction = Future<List<String>> Function();


void main() {
  LoadDataFunction loadDataFun;

  const load = String.fromEnvironment("LOAD");
  // use with `flutter run --dart-define="LOAD=error"`
  // https://en.wikipedia.org/wiki/Dependency_injection
  if (load == "error") {
    loadDataFun = loadError;
  }
  else {
    loadDataFun = loadData;
  }

  runApp(AppContext(
      child: const App(),
      loadDataFun: loadDataFun,
  ));
}


const String app_title = "Perretes App";


class AppContext extends InheritedWidget {
  AppContext({super.key, required super.child, required this.loadDataFun});

  final LoadDataFunction loadDataFun;

  static AppContext of(BuildContext context) {
    final AppContext? result = context.dependOnInheritedWidgetOfExactType<AppContext>();
    assert(result != null, 'No AppContext found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppContext old) => this.loadDataFun != old.loadDataFun;
}

class App extends StatelessWidget {
  final String title;

  const App({this.title = app_title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ListFromFileScreen(title: title),
    );
  }
}

class ListFromFileScreen extends StatelessWidget {
  final String title;

  ListFromFileScreen({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: ListFromFile(breeds: AppContext.of(context).loadDataFun())
    );
  }
}


class ListFromFile extends StatelessWidget {
  final Future<List<String>> breeds;

  ListFromFile({required this.breeds});

  @override
  Widget build(BuildContext context) {
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline5?.fontSize
    );

    // Reducimos boilerplate usando un Widget de la librería.
    return FutureBuilder(
      future: breeds,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.asset('images/snoopy-penalty-box.gif'),
                  Text('There was a error reading the file'),
                ],
              ),
            ),
          );
        }
        else if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        else {
          List<String> data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int i) =>
            ListTile(
              title: Text(data[i], style: fontStyle),
            )
          );
        };
      },
    );
  }
}



Future<List<String>> loadData() async {
  String json = await rootBundle.loadString('data/breeds_list.json');
  Map data = jsonDecode(json);
  return data['message'].keys.toList();
}


Future<List<String>> loadError() async {
  await Future.delayed(Duration(seconds: 2));
  throw FlutterError("could not read file");
}



