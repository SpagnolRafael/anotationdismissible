// ignore_for_file: import_of_legacy_library_into_null_safe, unused_local_variable

import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/model/anotacao.dart';
import 'package:minhas_anotacoes/helper/AnotationHelper.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  // ignore: prefer_final_fields
  var _database = AnotationHelper();
  List<Anotacao> anotacoes = [];

  _exibirPopUP({Anotacao? anotacao}) {
    String? textoSalvarAtualizar;
    if (anotacao == null) {
      _controller1.text = "";
      _controller2.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      _controller1.text = anotacao.titulo.toString();
      _controller2.text = anotacao.descricao.toString();
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$textoSalvarAtualizar Anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: TextField(
                  controller: _controller1,
                  autofocus: true,
                  decoration: const InputDecoration(
                    //labelText: "Digite o Título",
                    hintText: "Digite o Título",
                  ),
                ),
              ),
              TextField(
                controller: _controller2,
                decoration: const InputDecoration(
                  //labelText: "Digite o Título",
                  hintText: "Digite a descrição",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _salvarAnotacao(anotacaoSelect: anotacao);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                      child: Text(
                        "$textoSalvarAtualizar",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  _salvarAnotacao({Anotacao? anotacaoSelect}) async {
    String titulo = _controller1.text;
    String descricao = _controller2.text;
    String data =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    if (anotacaoSelect == null) {
      //String data = DateTime.now().toString();

      Anotacao anotacao = Anotacao(titulo, descricao, data);
      int resultado = await _database.salvarAnotacao(anotacao);
    } else {
      anotacaoSelect.titulo = titulo;
      anotacaoSelect.descricao = descricao;
      anotacaoSelect.data =
          "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()}";
      int resultado = await _database.atualizarAnotacao(anotacaoSelect);
    }
    _controller1.clear();
    _controller2.clear();

    _recuperarAnotacao();
  }

  _recuperarAnotacao() async {
    List anotacoesRecuperadas = await _database.recuperarAnotacao();
    List<Anotacao> listaTemporaria = [];
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }
    setState(() {
      anotacoes = listaTemporaria;
    });
    listaTemporaria = [];
  }

  _removerAnotacao(int id) async {
    await _database.removerAnotacao(id);
    _recuperarAnotacao();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Anotações",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.search),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.add_alert_outlined),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.account_circle),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              final anotacao = anotacoes[index];
              return Card(
                color: const Color.fromARGB(213, 17, 142, 180),
                child: Dismissible(
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      setState(() {
                        _removerAnotacao(anotacao.id!);
                      });
                    }
                  },
                  direction: DismissDirection.endToStart,
                  key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.only(
                      right: 20,
                    ),
                    alignment: AlignmentDirectional.centerEnd,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              anotacao.data.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                              ),
                              child: Text(
                                anotacao.titulo.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                          child: Text(
                            "${anotacao.descricao}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            _exibirPopUP(anotacao: anotacao);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: anotacoes.length,
          ))
        ],
      ),
      backgroundColor: Colors.blueGrey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _exibirPopUP,
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          size: 35,
        ),
      ),
    );
  }
}
