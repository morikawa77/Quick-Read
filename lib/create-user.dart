import 'package:flutter/material.dart'; // Importa o pacote de widgets do Flutter
import 'package:firebase_auth/firebase_auth.dart'; // Importa o pacote do Firebase para autenticação de usuários
import 'package:quick_read/login.dart'; // Importa a página de login
import 'package:quick_read/resumo.dart'; // Importa a página de resumo
import 'package:quick_read/degrade.dart'; // Importa o Container com o degrade de fundo

// Define a página de criação de usuário como um widget com estado
class CreateUserPage extends StatefulWidget {
  const CreateUserPage(
      {super.key}); // Construtor da página de criação de usuário

  @override
  _CreateUserPageState createState() =>
      _CreateUserPageState(); // Cria o estado da página
}

// Classe que gerencia o estado da página de criação de usuário
class _CreateUserPageState extends State<CreateUserPage> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de nome, e-mail e senha
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instância do Firebase Authentication
  final _auth = FirebaseAuth.instance;

  // Variável para controlar o estado de carregamento
  bool _isLoading = false;

  // Função que lida com a criação de novo usuário
  Future<void> _handleCreateUser(BuildContext context) async {
    // Verifica se o formulário é válido
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Ativa o estado de carregamento
      });
      try {
        final name = _nameController.text.trim(); // Obtém o nome digitado
        final email = _emailController.text.trim(); // Obtém o e-mail digitado
        final password =
            _passwordController.text.trim(); // Obtém a senha digitada

        // Cria o usuário com o e-mail e senha no Firebase
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // Atualiza o perfil do usuário com o nome
        await _auth.currentUser?.updateDisplayName(name);

        // Redireciona para a página de resumo após a criação da conta
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ResumoPage()));
      } on FirebaseAuthException catch (e) {
        // Exibe uma mensagem de erro se a criação do usuário falhar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar usuário: ${e.message}'),
          ),
        );
      } finally {
        // Desativa o estado de carregamento
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o usuário já está autenticado
    if (_auth.currentUser != null) {
      return ResumoPage(); // Se já estiver logado, vai diretamente para a página de resumo
    } else {
      // Se o usuário não estiver autenticado, exibe a tela de criação de conta
      return Material(
        child: GradientContainer(
          child: Scaffold(
            backgroundColor: Colors
                .transparent, // Define o fundo do Scaffold como transparente
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back), // Ícone de voltar
                onPressed: () {
                  // Redireciona para a página de login ao clicar no botão de voltar
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => LoginPage()));
                },
              ),
              title: const Text('QUICK READ'), // Define o título na AppBar
            ),
            body: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(
                    16), // Define uma margem ao redor do conteúdo
                child: Form(
                  key:
                      _formKey, // Associa o formulário à chave GlobalKey para validação
                  child: Column(
                    children: [
                      // Campo de texto para o nome
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome', // Rótulo do campo
                        ),
                        // Validação do campo de nome
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o seu nome'; // Exibe mensagem se o campo estiver vazio
                          }
                          return null; // Retorna null se não houver erros
                        },
                      ),
                      const SizedBox(height: 16), // Espaço entre os campos

                      // Campo de texto para o e-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType
                            .emailAddress, // Define o tipo de teclado para e-mail
                        decoration: const InputDecoration(
                          labelText: 'E-mail', // Rótulo do campo
                        ),
                        // Validação do campo de e-mail
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o seu e-mail'; // Exibe mensagem se o campo estiver vazio
                          }
                          return null; // Retorna null se não houver erros
                        },
                      ),
                      const SizedBox(height: 16), // Espaço entre os campos

                      // Campo de texto para a senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText:
                            true, // Oculta o texto ao digitar (para senhas)
                        decoration: const InputDecoration(
                          labelText: 'Senha', // Rótulo do campo
                        ),
                        // Validação do campo de senha
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe a sua senha'; // Exibe mensagem se o campo estiver vazio
                          }
                          return null; // Retorna null se não houver erros
                        },
                      ),
                      const SizedBox(height: 32), // Espaço antes do botão

                      // Botão para criar o usuário
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null // Desabilita o botão se estiver carregando
                            : () => _handleCreateUser(
                                context), // Chama a função de criação de usuário
                        child: _isLoading
                            ? const CircularProgressIndicator
                                .adaptive() // Exibe um indicador de carregamento se estiver processando
                            : const Text('CRIAR CONTA'), // Texto do botão
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
