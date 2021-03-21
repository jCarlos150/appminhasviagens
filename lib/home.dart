import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minhasViagens/mapa.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List viagens = ["Hell", "Sky", "Eart", "Disney", "Limbo"];

  final _controler = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;

  _adcionalerListner() async {
    final stream = _db.collection("viagens").snapshots();

    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  void abrirMapp(String idviagen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => Mapa(idviagem: idviagen)));
  }

  void openMapa() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Mapa()));
  }

  void exluir(String idviagen) {
    _db.collection("viagens").document(idviagen).delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adcionalerListner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset("imagens/logo.png", height: 50),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            openMapa();
          },
          backgroundColor: Color(0xff0066cc),
          child: Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _controler.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  QuerySnapshot snapshots = snapshot.data;
                  List<DocumentSnapshot> viagens = snapshots.documents.toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: viagens.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot item = viagens[index];
                              String titulo = item["titulo"];
                              String idViagem = item.documentID;

                              return GestureDetector(
                                onTap: () {
                                  abrirMapp(idViagem);
                                },
                                child: Card(
                                  child: ListTile(
                                    title: Text(titulo),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            exluir(idViagem);
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                    ],
                  );
              }
            }));
  }
}
