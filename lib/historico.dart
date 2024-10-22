import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'resumo.model.dart'; // Importa a classe Resumo existente

class HistoricoPage extends StatefulWidget {
  @override
  _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  Stream<List<Resumo>>? resumosStream;

  @override
  void initState() {
    super.initState();

    // Obtém o usuário logado pelo Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;

    // Se o usuário estiver autenticado, obtém os resumos do Firestore filtrando pelo userId
    if (user != null) {
      resumosStream = FirebaseFirestore.instance
          .collection('resumos') // Referência à coleção 'resumos'
          .where('userId',
              isEqualTo: user.uid) // Filtra resumos do usuário logado
          .orderBy('data',
              descending:
                  true) // Ordena os resumos pela data em ordem decrescente
          .snapshots() // Retorna um Stream de snapshots do Firestore
          .map((snapshot) =>
              // Mapeia os documentos do snapshot para objetos Resumo
              snapshot.docs.map((doc) => Resumo.fromJson(doc.data())).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Read - Histórico'), // Título da AppBar
      ),
      body: StreamBuilder<List<Resumo>>(
        // StreamBuilder para construir a interface com base no stream de resumos
        stream: resumosStream, // Stream de dados
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Verifica se houve um erro na obtenção dos dados
            return const Text('Algo deu errado'); // Mensagem de erro
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Exibe um indicador de carregamento enquanto os dados estão sendo obtidos
            return const CircularProgressIndicator
                .adaptive(); // Indicador de carregamento adaptável
          }

          // Constrói a lista de resumos após obter os dados
          return ListView.builder(
            itemCount: snapshot.data?.length, // Número de itens na lista
            itemBuilder: (context, index) {
              final resumo =
                  snapshot.data![index]; // Pega o resumo atual da lista

              // Constrói um item da lista (ListTile) para cada resumo
              return ListTile(
                title: Text(
                  // Limita o texto do resumo a 40 caracteres, mostrando "..." se for maior
                  resumo.resumo.length > 40
                      ? '${resumo.resumo.substring(0, resumo.resumo.indexOf(' ', 40))}...'
                      : resumo.resumo,
                  maxLines: 1, // Limita o título a 1 linha
                  overflow: TextOverflow
                      .ellipsis, // Corta o texto com "..." se ultrapassar o limite
                ),
                subtitle: Text(
                    resumo.data.toDate().toString()), // Mostra a data do resumo
                onTap: () {
                  // Quando o item da lista é tocado, exibe o conteúdo completo do resumo em um diálogo
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Resumo'), // Título do diálogo
                        content:
                            Text(resumo.resumo), // Conteúdo completo do resumo
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fecha o diálogo
                            },
                            child: const Text(
                                'Fechar'), // Botão para fechar o diálogo
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
