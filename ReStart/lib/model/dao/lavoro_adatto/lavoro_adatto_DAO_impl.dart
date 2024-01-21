import 'package:postgres/postgres.dart';

import '../../connection/connector.dart';
import '../../entity/utente_DTO.dart';
import 'lavoro_adatto_DAO.dart';
import 'dart:developer' as developer;

/// Implementazione di [LavoroAdattoDAO] per interagire con un database PostgreSQL.
class LavoroAdattoDAOImpl implements LavoroAdattoDAO {
  Connector connector = Connector();

  /// Aggiorna il lavoro adatto per un utente specifico nel database.
  ///
  /// Aggiorna il campo [lavoro_adatto] dell'utente identificato da [UtenteDTO.id] con la stringa [lavoroAdatto].
  /// Aggiorna anche i campi associati all'utente nelle tabelle correlate (es. Contatti, Indirizzo, Immagine).
  /// Restituisce [true] se l'aggiornamento è andato a buon fine, altrimenti [false].
  @override
  Future<bool> update(String lavoroAdatto, UtenteDTO u) async {
    try {
      Connection connection = await connector.openConnection();
      var result1 = await connection.execute(
        Sql.named(
            'UPDATE public."Utente" SET nome = @nome, cognome = @cognome, cod_fiscale = @cod_fiscale, data_nascita = @data_nascita, luogo_nascita = @luogo_nascita, '
            'genere = @genere, username = @username, password = @password, lavoro_adatto = @lavoro_adatto WHERE id = @id'),
        parameters: {
          'id': u.id,
          'nome': u.nome,
          'cognome': u.cognome,
          'cod_fiscale': u.cod_fiscale,
          'data_nascita': u.data_nascita,
          'luogo_nascita': u.luogo_nascita,
          'genere': u.genere,
          'username': u.username,
          'password': u.password,
          'lavoro_adatto': lavoroAdatto
        },
      );

      var result2 = await connection.execute(
        Sql.named(
            'UPDATE public."Contatti" SET email = @email, num_telefono = @num_telefono '
            'WHERE id_utente = @id_utente'),
        parameters: {
          'email': u.email,
          'num_telefono': u.num_telefono,
          'id_utente': u.id,
        },
      );

      var result3 = await connection.execute(
        Sql.named(
            'UPDATE public."Indirizzo" SET via = @via, citta = @citta, provincia = @provincia '
            'WHERE id_utente = @id_utente'),
        parameters: {
          'via': u.via,
          'citta': u.citta,
          'provincia': u.provincia,
          'id_utente': u.id
        },
      );

      var result4 = await connection.execute(
          Sql.named('UPDATE public."Immagine" SET immagine = @immagine '
              'WHERE id_utente = @id'),
          parameters: {'immagine': u.immagine, 'id': u.id});

      if (result1.affectedRows != 0 &&
          result2.affectedRows != 0 &&
          result3.affectedRows != 0 &&
          result4.affectedRows != 0) {
        return true;
      }
      return false;
    } catch (e) {
      developer.log(e.toString());
      return false;
    } finally {
      connector.closeConnection();
    }
  }
}
