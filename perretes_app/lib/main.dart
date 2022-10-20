import 'dart:async';
import 'package:flutter/material.dart';


import 'package:perretes_app/app.dart';
import 'package:perretes_app/state.dart';


void main() {
  // Si no inicializamos aquí, salta la excepción :(
  // [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: Binding has not
  // yet been initialized.

  WidgetsFlutterBinding.ensureInitialized();

  RandomPhotos photos = RandomPhotos(client: DogCEOClient());
  runApp(
    PerretesContext(
      breeds: loadBreeds(),
      photosStream: photos.photosStream,
      breedStreamController: photos.breedStreamController,
      child: const PerretesApp(),
    )
  );
}


