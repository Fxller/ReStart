import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../model/entity/utente_DTO.dart';
import '../../../utils/auth_service.dart';
import '../../components/generic_app_bar.dart';
import 'package:http/http.dart' as http;

import '../routes/routes.dart';

class ListaUtenti extends StatefulWidget {
  ListaUtenti({super.key});

  @override
  State<ListaUtenti> createState() => _ListaUtentiState();
}

class _ListaUtentiState extends State<ListaUtenti> {
  List<UtenteDTO> utenti = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
    _checkUserAndNavigate();
  }
  void _checkUserAndNavigate() async {
    bool isUserValid = await AuthService.checkUserADS();
    if (!isUserValid) {
      Navigator.pushNamed(context, AppRoutes.home);
    }
  }
  Future<void> fetchDataFromServer() async {
    final response = await http
        .post(Uri.parse('http://10.0.2.2:8080/autenticazione/listaUtenti'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('utenti')) {
        final List<UtenteDTO> data =
        List<Map<String, dynamic>>.from(responseBody['utenti'])
            .map((json) => UtenteDTO.fromJson(json))
            .toList();
        setState(() {
          utenti = data;
        });
      } else {
        print('Chiave "utenti" non trovata nella risposta.');
      }
    } else {
      print('Errore');
    }
  }

  Future<void> deleteUtente(UtenteDTO utente) async {
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/autenticazione/deleteUtente'),
        body: jsonEncode(utente));
    if (response.statusCode == 200) {
      setState(() {
        utenti.remove(utente);
      });
    } else {
      print("Eliminazione non andata a buon fine");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: GenericAppBar(
          showBackButton: true,
        ),
        endDrawer: GenericAppBar.buildDrawer(context),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: const Text(
                  'Lista utenti',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ListView.builder(
                  itemCount: utenti.length,
                  itemBuilder: (context, index) {
                    final utente = utenti[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Colors.blue[50]!, Colors.blue[100]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: ListTile(
                            visualDensity: const VisualDensity(vertical: 4, horizontal: 4),
                            minVerticalPadding: 50,
                            minLeadingWidth: 80,
                            tileColor: Colors.transparent,
                            leading: const CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(
                                'https://img.freepik.com/free-vector/men-success-laptop-relieve-work-from-home-computer-great_10045-646.jpg?size=338&ext=jpg&ga=GA1.1.1546980028.1703635200&semt=ais',
                              ),
                            ),
                          title: Text(
                            utente.nome,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            utente.email,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black, size: 30),
                            onPressed: () {
                              deleteUtente(utente);
                                },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(ListaUtenti());
}