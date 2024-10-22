import 'package:flutter_gemini/flutter_gemini.dart'; // Importa o pacote flutter_gemini para integração com API
import 'package:quick_read/historico.dart';
import 'firebase_options.dart'; // Importa configurações específicas do Firebase
import 'package:firebase_core/firebase_core.dart'; // Importa o núcleo do Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa o Firestore
import 'package:flutter/material.dart'; // Importa o pacote principal de componentes visuais do Flutter
import 'package:quick_read/login.dart'; // Importa a tela de login
import 'package:quick_read/create-user.dart'; // Importa a tela de criação de usuário
import 'package:quick_read/resumo.dart'; // Importa a tela de resumo

// Função principal do app
void main() {
  // Garante que o Flutter seja inicializado corretamente antes de qualquer código ser executado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a API Gemini com a chave fornecida
  // A chave da API é usada para autenticar a comunicação com o serviço Gemini
  Gemini.init(apiKey: 'AIzaSyB7Zb52SdHPEnTAhCGjdhbcGIMQ652_hVE');

  // Executa o aplicativo Flutter
  runApp(const MyApp());
}

// Classe principal do aplicativo, responsável por configurar o app
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Construtor padrão

  @override
  Widget build(BuildContext context) {
    // Define a direção do texto como da esquerda para a direita (LTR - Left to Right)
    return Directionality(
      textDirection: TextDirection.ltr,

      // O FutureBuilder aguarda a inicialização do Firebase
      // É usado para construir a interface com base no estado da inicialização
      child: FutureBuilder(
        future: _initializeFirebase(),

        // Constrói a interface dependendo do estado de inicialização do Firebase
        builder: (context, snapshot) {
          // Caso haja erro ao inicializar o Firebase
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                  "Erro ao inicializar o Firebase"), // Exibe mensagem de erro
            );
          }

          // Enquanto o Firebase está inicializando
          // O estado "waiting" indica que o processo ainda está em andamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator
                  .adaptive(), // Exibe um indicador de carregamento
            );
          }

          // Se o Firebase foi inicializado com sucesso, constrói o MaterialApp
          return MaterialApp(
            // Definições de tema para o app
            theme: ThemeData(
                // Configurações de tema da AppBar
                appBarTheme: const AppBarTheme(
                    iconTheme: IconThemeData(
                        color: Colors.white), // Ícones brancos na AppBar
                    backgroundColor:
                        Color(0xff130059), // Cor de fundo da AppBar
                    titleTextStyle: TextStyle(
                      fontSize: 36, // Tamanho da fonte do título
                      fontWeight: FontWeight.bold, // Fonte em negrito
                      color: Colors.white, // Cor do texto do título
                    )),
                // Configurações de tema para os campos de input
                inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white, // Cor de fundo dos campos
                    labelStyle: const TextStyle(
                        color: Colors.black), // Cor do texto dos labels
                    contentPadding: const EdgeInsets.fromLTRB(
                        20, 10, 20, 10), // Padding interno
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(25.0), // Bordas arredondadas
                    )),
                // Tema dos botões elevados
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, // Cor do texto dos botões
                    backgroundColor: Colors.white, // Cor de fundo dos botões
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold), // Texto em negrito
                    elevation: 4.0, // Sombra dos botões
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          16.0), // Bordas arredondadas dos botões
                    ),
                  ),
                ),
                // Tema dos botões delineados
                outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white, // Cor do texto dos botões
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, // Texto em negrito
                  ),
                ))),

            debugShowCheckedModeBanner: false, // Remove o banner de debug
            initialRoute: '/login', // Rota inicial do app
            // As rotas definem o caminho para diferentes telas do aplicativo
            routes: {
              '/login': (context) => LoginPage(), // Rota para a tela de login
              '/create-user': (context) =>
                  CreateUserPage(), // Rota para a tela de criação de usuário
              '/resumo': (context) =>
                  ResumoPage(), // Rota para a tela de resumo
              '/historico': (context) => HistoricoPage(),
            },
          );
        },
      ),
    );
  }
}

// Função que inicializa o Firebase de forma assíncrona
// A função tenta iniciar o Firebase e retorna a instância se for bem-sucedido
Future<FirebaseApp?> _initializeFirebase() async {
  try {
    // Tenta inicializar o Firebase com as opções da plataforma atual (Android, iOS, etc.)
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return app; // Retorna o app inicializado com sucesso
  } catch (e) {
    print(
        'Error initializing Firebase: $e'); // Exibe erro no console caso a inicialização falhe
    return null; // Retorna null em caso de erro
  }
}
