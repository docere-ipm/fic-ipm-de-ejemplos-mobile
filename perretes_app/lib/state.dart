import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;


class RandomPhotos {
  final DogCEOClient client;
  final StreamController<String> photosStreamController = StreamController.broadcast();
  final StreamController<String> breedStreamController = StreamController();

  String? breed;

  Stream<String> get photosStream => photosStreamController.stream;
  
  RandomPhotos({required this.client}) {
    photosStreamController.onListen = () { requestPhoto(); };
    breedStreamController.stream.listen(
      (String breed) {
        this.breed = breed;
        requestPhoto();
      },
    );
  }

  void requestPhoto() {
    String? selected = breed;
    if (selected != null) {
      client.loadBreedImageURL(selected).then(
        (String url) { photosStreamController.add(url); }
      ).catchError(
        (Object error) { photosStreamController.addError(error); return ''; },
      );
    }
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
Future<List<String>> loadBreeds() async {
  String json = await rootBundle.loadString('data/breeds_list.json');
  Map data = jsonDecode(json);
  return data['message'].keys.toList();
}
