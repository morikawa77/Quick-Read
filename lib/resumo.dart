import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Importa o pacote de widgets do Flutter
import 'package:firebase_auth/firebase_auth.dart'; // Importa o pacote do Firebase para autenticação de usuários
import 'package:flutter_markdown/flutter_markdown.dart'; // Importa a biblioteca de markdown
import 'package:image_picker/image_picker.dart'; // Importa a biblioteca de selecionar imagem
import 'package:flutter_gemini/flutter_gemini.dart'; // Importa a biblioteca do Gemini
import 'package:flutter/foundation.dart'; // Importa tipos primitivos do Flutter
import 'package:quick_read/degrade.dart';
import 'package:quick_read/resumo.model.dart'; // Importa o Container com o degrade de fundo

class ResumoPage extends StatefulWidget {
  @override
  _ResumoPageState createState() => _ResumoPageState();
}

class _ResumoPageState extends State<ResumoPage> {
  String qtdPalavras = "60"; // Quantidade de palavras do resumo
  Uint8List? _imageBytes; // Armazena a imagem como bytes (Uint8List)
  bool _isLoading = false; // Controla o estado de carregamento
  String? _result; // Armazena o resultado do resumo
  final _auth = FirebaseAuth.instance; // Instância do Firebase Authentication
  final gemini = Gemini.instance; // Instância do Firebase Authentication

  // Função para deslogar do Firebase
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Função para selecionar uma imagem da galeria
  Future<Uint8List?> _galleryImagePicker() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file != null) return await file.readAsBytes();
    return null;
  }

  // Função para tirar uma foto usando a câmera
  Future<Uint8List?> _cameraImagePicker() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (file != null) return await file.readAsBytes();
    return null;
  }

  // Função que processa a imagem e envia para a API do Gemini
  Future<void> _processImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true; // Inicia o estado de loading
      _result = null; // Limpa o resultado anterior
    });

    try {
      // Chama o método textAndImage para processar a imagem
      final result = await gemini.textAndImage(
        text:
            'Faça um resumo conciso do texto presente nesta imagem em no máximo $qtdPalavras palavras', // Texto adicional
        images: [_imageBytes!], // Envia a imagem como bytes
      );

      setState(() {
        _result = result?.output ??
            'Nenhum resumo disponível'; // Atualiza o estado com o resumo
        final user = FirebaseAuth.instance.currentUser;
        final resumo = Resumo(
          userId: user!.uid,
          data: Timestamp.now(),
          resumo: result?.output ?? 'Nenhum resumo disponível',
        );

        FirebaseFirestore.instance
            .collection('resumos')
            .add(resumo.toJson())
            .then((value) => print("Resumo adicionado"))
            .catchError((error) => print("Failed to add resumo: $error"));
      });
    } catch (e) {
      setState(() {
        _result =
            'Erro ao processar a imagem: $e'; // Exibe erro em caso de falha
      });
    } finally {
      setState(() {
        _isLoading = false; // Finaliza o estado de loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userName =
        _auth.currentUser?.displayName; // Pega o nome do usuário autenticado
    return GradientContainer(
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Define o fundo do Scaffold como transparente
        appBar: AppBar(
          title: const Text('Quick Read'),
          backgroundColor: const Color(0xff130059),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout, // Botão para deslogar do Firebase
              tooltip: 'Deslogar',
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Alinha ao topo
            children: [
              Expanded(
                child: GeminiResponseTypeView(
                  builder: (context, child, result, loading) {
                    if (loading) {
                      // Exibe uma animação de carregamento enquanto a imagem está sendo processada
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    // Verifica se o resultado não é nulo e exibe o conteúdo diretamente
                    if (_result != null) {
                      return Container(
                        padding:
                            const EdgeInsets.all(16), // Espaçamento interno
                        margin: const EdgeInsets.all(16), // Margem externa
                        decoration: BoxDecoration(
                          color: Colors.white, // Cor de fundo
                          borderRadius:
                              BorderRadius.circular(25), // Bordas arredondadas
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Cor da sombra
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 3), // Posição da sombra
                            ),
                          ],
                        ),
                        child: Markdown(
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          data: _result!,
                          selectable: true,
                        ),
                      );
                    } else {
                      // Estado ocioso, quando não há resposta ou resultado é nulo
                      return Center(
                        child: Text(
                          '${userName!}, envie uma imagem para obter o resumo do texto.',
                          style: const TextStyle(
                            color: Colors
                                .white, // Define a cor do texto como branco
                            fontWeight:
                                FontWeight.bold, // Define o texto como negrito
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              if (_imageBytes != null) // Exibe a prévia da imagem selecionada
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image.memory(_imageBytes!,
                      height: 240, fit: BoxFit.cover),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Exibe o primeiro ElevatedButton apenas se não for Web
                  if (!kIsWeb)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final Uint8List? image =
                            await _cameraImagePicker(); // Tirar foto com a câmera
                        if (image != null) {
                          setState(() {
                            _imageBytes = image;
                          });
                          await _processImage();
                        }
                      },
                      icon: const Icon(Icons.add_a_photo_rounded),
                      label: const Text('Tirar Foto'),
                    ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final Uint8List? image =
                          await _galleryImagePicker(); // Selecionar da galeria
                      if (image != null) {
                        setState(() {
                          _imageBytes = image;
                        });
                        await _processImage();
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate_rounded),
                    label: const Text('Escolher da Galeria'),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/historico');
                    },
                    icon: const Icon(Icons.access_time_rounded),
                    label: const Text('Histórico'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
