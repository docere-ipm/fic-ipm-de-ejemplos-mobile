import 'package:flutter/material.dart';


const String app_title = "Perretes App";
const int breakPoint = 600;


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
                : BreedDetail(breed: breed)
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
const List<String> data = [ "Affenpinscher", "Pomeranian" ];


class BreedsList extends StatelessWidget {
  final void Function(String breed) onBreedSelected;

  BreedsList({required this.onBreedSelected});
  
  @override
  Widget build(BuildContext context) {
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline5?.fontSize
    );
  
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int i) =>
      ListTile(
        title: Text(data[i], style: fontStyle),
        onTap: () { this.onBreedSelected(data[i]); },
      )
    );
  }
}


class BreedDetail extends StatelessWidget {
  final String breed;

  const BreedDetail({required this.breed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        child: Image.asset('images/avatar-snoopy.jpeg'),
      )
    );
  }
}
