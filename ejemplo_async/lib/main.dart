import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}


const String app_title = "Perretes App";


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
      body: ListFromFile()
    );
  }
}


class ListFromFile extends StatefulWidget {
  @override
  _ListFromFileState createState() => _ListFromFileState();
}


class _ListFromFileState extends State<ListFromFile> {
  Future<List<String>>? _breeds;

  @override
  void initState() {
    super.initState();
    _breeds = _loadData();
  }

  // Este método hace E/S, si no lo marcamos como asíncrono, no compila
  Future<List<String>> _loadData() async {
    AssetBundle asset = DefaultAssetBundle.of(context);
    String json = await asset.loadString('data/breeds_list.json');
    Map data = jsonDecode(json);
    return data['message'].keys.toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline5?.fontSize
    );

    // Reducimos boilerplate usando un Widget de la librería.
    return FutureBuilder(
      future: _breeds,
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

