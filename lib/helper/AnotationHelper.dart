// ignore_for_file: empty_constructor_bodies, file_names

import 'package:minhas_anotacoes/model/anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotationHelper {
  static const String nomeTabela = "anotacao";
  static final AnotationHelper _anotationHelper = AnotationHelper._internal();
  Database? _database;

  factory AnotationHelper() {
    return _anotationHelper;
  }

  AnotationHelper._internal() {}

  get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await inicializarDatabase();
      return _database;
    }
  }

  inicializarDatabase() async {
    final caminhoBanco = await getDatabasesPath();
    final localBanco = join(caminhoBanco, "banco_minhas_anotacoes_app.db");
    var database = await openDatabase(
      localBanco,
      version: 1,
      onCreate: _onCreate,
    );
    return database;
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE $nomeTabela ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "titulo VARCHAR, "
        "descricao TEXT, "
        "data DATETIME)";
    await db.execute(sql);
  }

  recuperarAnotacao() async {
    var bancoDados = await database;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bancoDados = await database;
    int resultado = await bancoDados.insert(nomeTabela, anotacao.toMap());
    return resultado;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDados = await database;
    return await bancoDados.update(nomeTabela, anotacao.toMap(),
        where: "id = ?", whereArgs: [anotacao.id]);
  }

  Future<int> removerAnotacao(int id) async {
    var bancoDados = await database;
    return await bancoDados
        .delete(nomeTabela, where: "id = ?", whereArgs: [id]);
  }
}
