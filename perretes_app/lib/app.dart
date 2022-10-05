import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';


const String app_title = "Perretes App";
const int breakPoint = 600;
const DogCEOClient client = DogCEOClient();

class PerretesApp extends StatelessWidget {
  final String title;

  const PerretesApp({this.title = app_title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MasterDetail(title: title),
    );
  }
}


class MasterDetail extends StatelessWidget {
  final String title;

  MasterDetail({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool chooseMasterAndDetail = (
          constraints.smallest.longestSide > breakPoint &&
          MediaQuery.of(context).orientation == Orientation.landscape
        );
        return chooseMasterAndDetail ? MasterAndDetailScreen(title: title) : BreedsListScreen(title: title);
      }
    );
  }
}


/*
 * Diseño con dos pantallas 
 */

class BreedsListScreen extends StatelessWidget {
  final String title;

  BreedsListScreen({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: BreedsList(
        onBreedSelected: (String breed) async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BreedDetailScreen(breed: breed),
            ),
          );
        }
      ),
    );
  }
}


class BreedDetailScreen extends StatelessWidget {
  final String breed;

  const BreedDetailScreen({required this.breed});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$app_title : $breed'),
      ),
      body: BreedDetail(breed: breed),
    );
  }

}


/*
 * Diseño Master and Detail en una pantalla
 */

class MasterAndDetailScreen extends StatelessWidget {
  final String title;
  final ValueNotifier<String?> _breed = ValueNotifier<String?>(null);

  MasterAndDetailScreen({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app_title),
      ),
      body: Row(
        children: <Widget>[
          Flexible(
            flex: 13,
            child: Material(
              elevation: 4.0,
              child: BreedsList(
                onBreedSelected: (String breed) { _breed.value = breed; }
              ),
            ),
          ),
          Flexible(
            flex: 27,
            child: ValueListenableBuilder(
              valueListenable: _breed,
              builder: (BuildContext context, String? breed, Widget? child) {
                return breed == null
                ? Center(
                  child: Text(
                    'Please select a breed from the list',
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.center,
                  )
                )
                : BreedDetail(key: ValueKey(breed), breed: breed)
                ;
              },
            ),
          ),
        ]
      ),
    );
  }
}


/*
 * Widgets con el contenido de las pantallas
 */
class BreedsList extends StatefulWidget {
  final void Function(String breed) onBreedSelected;

  BreedsList({required this.onBreedSelected});

  @override
  _BreedsListState createState() => _BreedsListState();
}


class _BreedsListState extends State<BreedsList> {
  Future<List<String>>? _breeds;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _breeds = _loadData();
  }

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
              onTap: () { widget.onBreedSelected(data[i]); },
            )
          );
        }
      },
    );
  }
}


class BreedDetail extends StatefulWidget {
  final String breed;

  const BreedDetail({required this.breed, key}) : super(key: key);

  @override
  _BreedDetailState createState() => _BreedDetailState();
}

class _BreedDetailState extends State<BreedDetail> {
  Future<String>? _randomUrl;

  @override
  void initState() {
    super.initState();
    _reload();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String> (
      future: _randomUrl,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.asset('images/snoopy-penalty-box.gif'),
                  Text('There was a network error'),
                  ElevatedButton(
                    child: Text('Try again'),
                    onPressed: () { _reload(); },
                  ),
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
          return Center(
            child: InkWell(
              child: Image.network(
                snapshot.data!,
              ),
              onTap: () { _reload(); },
            )
          );
        }
      },
    );  
  }

  void _reload() {
    Future<String> url = client.loadBreedImageURL(widget.breed);
    setState(() { _randomUrl = url; });
  }
}


/*
 * Cliente del servidor.
 */
class DogCEOClient {
  const DogCEOClient();
  
  Future<String> loadBreedImageURL(String breed) async {
    String url = "http://dog.ceo/api/breed/${breed}/images/random";
    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.OK) {
      throw 'Error getting IP address:\nHttp status ${response.statusCode}';
    }
    String json = await response.transform(utf8.decoder).join();
    Map data = jsonDecode(json);
    return data['message'];
  }
}
