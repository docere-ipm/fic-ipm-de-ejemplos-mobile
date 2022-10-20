import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';


const String app_title = "Perretes App";
const int breakPoint = 600;


class PerretesContext extends InheritedWidget {
  PerretesContext({
      super.key,
      required super.child,
      required this.breeds,
      required this.photosStream,
      required this.breedStreamController,
  });

  final Future<List<String>> breeds;
  final Stream<String> photosStream;
  final StreamController<String> breedStreamController;
  // Compartimos la selección entre todas las pantallas
  final ValueNotifier<String?> selectedBreed = ValueNotifier<String?>(null);

  void setSelected(String? breed) {
    selectedBreed.value = breed;
    if (breed != null) {
      breedStreamController.add(breed);
    }
  }
  
  static PerretesContext of(BuildContext context) {
    final PerretesContext? result = context.dependOnInheritedWidgetOfExactType<PerretesContext>();
    assert(result != null, 'No PerretesContext found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(PerretesContext old) => false;
}


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
        if (chooseMasterAndDetail) {
          PerretesContext.of(context).setSelected(null);
          return MasterAndDetailScreen(title: title);
        }
        else {
          return BreedsListScreen(title: title);
        }
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
            PerretesContext.of(context).setSelected(breed);
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

  MasterAndDetailScreen({required this.title});
  
  @override
  Widget build(BuildContext context) {
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline5?.fontSize
    );
    ValueNotifier<String?> selectedBreed = PerretesContext.of(context).selectedBreed;
    return Scaffold(
      appBar: AppBar(
        title: Text(app_title),
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedBreed, 
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
                    selected: selectedBreed.value == breed,
                    onTap: () {
                      PerretesContext.of(context).setSelected(breed);
                    },
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
  final Widget Function(String breed) tileBuilder;
  
  BreedsList({required this.tileBuilder});

  @override
  Widget build(BuildContext context) {
    final TextStyle fontStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.
      headline5?.fontSize
    );

    return FutureBuilder(
      future: PerretesContext.of(context).breeds,
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


class BreedDetail extends StatelessWidget {
  final String breed;

  const BreedDetail({required this.breed, key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String> (
      stream: PerretesContext.of(context).photosStream,
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
                    onPressed: () {
                      PerretesContext.of(context).setSelected(breed);
                    },
                  ),
                ],
              ),
            ),
          );
        }
        else if (!snapshot.hasData) {
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
              onTap: () {
                PerretesContext.of(context).setSelected(breed);
              }
            )
          );
        }
      },
    );  
  }
}
 
