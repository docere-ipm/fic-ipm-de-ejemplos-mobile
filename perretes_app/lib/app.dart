import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;


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
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline4?.fontSize
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: BreedsList(
        tileBuilder: (String breed) => ListTile(
          title: Text(breed, style: fontStyle),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BreedDetailScreen(breed: breed),
              ),
            );
          },
        ),
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
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline5?.fontSize
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(app_title),
      ),
      body: ValueListenableBuilder(
        valueListenable: _breed,
        builder: (BuildContext context, String? breed, Widget? child) =>
        Row(
          children: <Widget>[
            Flexible(
              flex: 13,
              child: Material(
                elevation: 4.0,
                child: BreedsList(
                  tileBuilder: (String breed) => ListTile(
                    title: Text(breed, style: fontStyle),
                    selected: _breed.value == breed,
                    onTap: () { _breed.value = breed; },
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 27,
              child: breed == null
                ? Center(
                  child: Text(
                    'Please select a breed from the list',
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.center,
                  )
                )
                : BreedDetail(key: ValueKey(breed), breed: breed),
              ),
          ],
        ),
      ),
    );
  }
}


/*
 * Widgets con el contenido de las pantallas
 */
class BreedsList extends StatelessWidget {
  final Future<List<String>> _breeds = loadData();
  final Widget Function(String breed) tileBuilder;
  
  BreedsList({required this.tileBuilder});

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
            itemBuilder: (BuildContext context, int i) => tileBuilder(data[i]),
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
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  double? value = loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                  : null;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(value: value),
                  );
                },
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


/*
 * Leer fichero de datos
 */ 
Future<List<String>> loadData() async {
  String json = await rootBundle.loadString('data/breeds_list.json');
  Map data = jsonDecode(json);
  return data['message'].keys.toList();
}
  
