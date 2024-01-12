import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:restart_all_in_one/utils/jwt_utils.dart';
import '../../../model/entity/evento_DTO.dart';
import '../../components/app_bar_ca.dart';
import 'package:http/http.dart' as http;
import '../routes/routes.dart';

/// Classe che implementa la sezione [CommunityEvents]
class CommunityEventsPubblicati extends StatefulWidget {
  @override
  _CommunityEventsState createState() => _CommunityEventsState();
}

/// Creazione dello stato di [CommunityEvents], costituito dalla lista degli eventi
class _CommunityEventsState extends State<CommunityEventsPubblicati> {
  List<EventoDTO> eventi = [];
  var token = SessionManager().get("token");

  /// Inizializzazione dello stato, con chiamata alla funzione [fetchDataFromServer]
  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
  }

  /// Metodo che permette di inviare la richiesta al server per ottenere la lista di tutti i [EventoDTO] presenti nel database
  Future<void> fetchDataFromServer() async {
    String user = JWTUtils.getUserFromToken(accessToken: await token);
    Map<String, dynamic> username = {"username": user};
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/gestioneEvento/eventiPubblicati'),
        body: json.encode(username));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('eventi')) {
        final List<EventoDTO> data =
            List<Map<String, dynamic>>.from(responseBody['eventi'])
                .map((json) => EventoDTO.fromJson(json))
                .toList();
        setState(() {
          List<EventoDTO> newData = [];
          for (EventoDTO e in data) {
            //if (e.approvato && e.id_ca == idCa) {
              newData.add(e);
            //}
          }
          eventi = newData;
        });
      } else {
        print('Chiave "eventi" non trovata nella risposta.');
      }
    } else {
      print('Errore');
    }
  }

  Future<void> deleteEvento(EventoDTO evento) async {
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/gestioneEvento/deleteEvento'),
        body: jsonEncode(evento));
    if (response.statusCode == 200) {
      setState(() {
        eventi.remove(evento);
      });
    } else {
      print("Eliminazione non andata a buon fine");
    }
  }

  /// Build del widget principale della sezione [CommunityEvents], contenente tutta l'interfaccia grafica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaAppBar(
        showBackButton: true,
      ),
      endDrawer: CaAppBar.buildDrawer(context),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: const Text(
                'GESTISCI I TUOI EVENTI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListView.builder(
              itemCount: eventi.length,
              itemBuilder: (context, index) {
                final evento = eventi[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.dettaglieventipub,
                      arguments: evento,
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 5, bottom: 5, right: 5),
                    child: ListTile(
                      visualDensity:
                          const VisualDensity(vertical: 4, horizontal: 4),
                      minVerticalPadding: 50,
                      minLeadingWidth: 80,
                      tileColor: Colors.grey,
                      leading: const CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(
                            'https://img.freepik.com/free-vector/men-success-laptop-relieve-work-from-home-computer-great_10045-646.jpg?size=338&ext=jpg&ga=GA1.1.1546980028.1703635200&semt=ais'),
                      ),
                      title: Text(evento.nomeEvento,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(evento.descrizione),
                      trailing: Container(
                        width: 100, // o un'altra dimensione adeguata
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.black, size: 30),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.modificaevento);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 30),
                              onPressed: () {
                                deleteEvento(evento);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class DetailsEventoPub extends StatefulWidget{
  @override
  _DetailsEventoPub createState() => _DetailsEventoPub();

}
/// Build del widget che viene visualizzato quando viene selezionato un determinato evento dalla sezione [CommunityEvents]
/// Permette di visualizzare i dettagli dell'evento selezionato
class _DetailsEventoPub extends State<DetailsEventoPub> {
  List<EventoDTO> eventi = [];
  var token = SessionManager().get("token");

  /// Inizializzazione dello stato, con chiamata alla funzione [fetchDataFromServer]
  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
  }

  /// Metodo che permette di inviare la richiesta al server per ottenere la lista di tutti i [EventoDTO] presenti nel database
  Future<void> fetchDataFromServer() async {
    String user = JWTUtils.getUserFromToken(accessToken: await token);
    Map<String, dynamic> username = {"username": user};
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/gestioneEvento/eventiPubblicati'),
        body: json.encode(username));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('eventi')) {
        final List<EventoDTO> data =
        List<Map<String, dynamic>>.from(responseBody['eventi'])
            .map((json) => EventoDTO.fromJson(json))
            .toList();
        setState(() {
          List<EventoDTO> newData = [];
          for (EventoDTO e in data) {
            //if (e.approvato && e.id_ca == idCa) {
            newData.add(e);
            //}
          }
          eventi = newData;
        });
      } else {
        print('Chiave "eventi" non trovata nella risposta.');
      }
    } else {
      print('Errore');
    }
  }

  Future<void> deleteEvento(EventoDTO evento) async {
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/gestioneEvento/deleteEvento'),
        body: jsonEncode(evento));
    if (response.statusCode == 200) {
      setState(() {
        eventi.remove(evento);
      });
    } else {
      print("Eliminazione non andata a buon fine");
    }
  }

  @override
  Widget build(BuildContext context) {
    final EventoDTO evento =
        ModalRoute.of(context)?.settings.arguments as EventoDTO;
    final String data = evento.date.toIso8601String();
    final String dataBuona = data.substring(0, 10);
    return Scaffold(
      appBar: CaAppBar(
        showBackButton: true,
      ),
      endDrawer: CaAppBar.buildDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      'https://img.freepik.com/free-vector/men-success-laptop-relieve-work-from-home-computer-great_10045-646.jpg?size=338&ext=jpg&ga=GA1.1.1546980028.1703635200&semt=ais'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            evento.nomeEvento,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(evento.descrizione),
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Contatti',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(evento.email),
                        Text(evento.sito),
                        const SizedBox(height: 20),
                        const Text(
                          'Informazioni',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(dataBuona),
                        // Aggiunta dei pulsanti sotto la sezione "Contatti"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.black, size: 40),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.modificaevento);
                              },
                            ),
                            const SizedBox(width: 20),
                            // Aggiungi uno spazio tra i pulsanti
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 40),
                              onPressed: () {
                                deleteEvento(evento);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )))
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CommunityEventsPubblicati(),
  ));
}
