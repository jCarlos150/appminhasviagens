import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget {
  String idviagem;

  Mapa({this.idviagem});

  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();

  Firestore _db = Firestore.instance;

  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-23.562436, -46.655005), zoom: 18);

  Set<Marker> marcadores = {};

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller); // função que cria o mapa
  }

  // movimentar Camera para a localização

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  _recuperarViagemParaId(String idViagem) async {
    if (idViagem != null) {
      DocumentSnapshot documentSnapshot =
          await _db.collection("viagens").document(idViagem).get();

      var dados = documentSnapshot.data;

      String titulo = dados["titulo"];
      LatLng latLng = LatLng(dados["latitude"], dados["longetude"]);
      setState(() {
        Marker marcador = Marker(
            markerId:
                MarkerId("marcador- ${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(title: titulo));

        marcadores.add(marcador);

        _cameraPosition = CameraPosition(target: latLng, zoom: 18);

        _movimentarCamera();
      });
    } else {
      _adicionarLocalizacaoListener();
    }
  }

  // pegar a localização
  _adicionarLocalizacaoListener() {
    var geolocator = Geolocator();
    var localtionOptions = LocationOptions(accuracy: LocationAccuracy.high);
    // ouvinte
    geolocator.getPositionStream(localtionOptions).listen((Position position) {
      setState(() {
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18);
      });
      _movimentarCamera();
    });
  }

  // exibir o marcador
  _showMarcador(LatLng latLng) async {
    List<Placemark> listaEnderecos = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (listaEnderecos != null || listaEnderecos.length > 0) {
      Placemark endereco = listaEnderecos[0];
      String rua = endereco.thoroughfare;
      Marker marcador = Marker(
          markerId: MarkerId("marcador ${latLng}"),
          position: latLng,
          infoWindow: InfoWindow(title: rua));

      setState(() {
        Map<String, dynamic> viagen = Map();
        viagen['titulo'] = rua;
        viagen['latitude'] = latLng.latitude;
        viagen['longetude'] = latLng.longitude;

        _db.collection("viagens").add(viagen);

        marcadores.add(marcador);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarViagemParaId(widget.idviagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Mapa"),
        ),
        body: Container(
          child: GoogleMap(
              markers: marcadores,
              mapType: MapType.normal,
              initialCameraPosition: _cameraPosition,
              onMapCreated: _onMapCreated,
              onLongPress: _showMarcador),
        ));
  }
}
