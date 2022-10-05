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
  List<String>? _breeds;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Este método hace E/S, si no lo marcamos como asíncrono, no compila
  Future<void> _loadData() async {
    AssetBundle asset = DefaultAssetBundle.of(context);
    try {
      String json = await asset.loadString('data/breeds_list.jsona');
      Map data = jsonDecode(json);
      setState(() {
          _error = false;
          _breeds = data['message'].keys.toList();
        }
      );
    }
    on FlutterError {
      setState(() {
          _error = true;
        }
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline5?.fontSize
    );

    if (_error) {
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
    else if (_breeds == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else {
      List<String> data = _breeds!;
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int i) =>
        ListTile(
          title: Text(data[i], style: fontStyle),
        )
      );
    }
  }
}

