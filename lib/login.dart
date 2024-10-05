import 'package:flutter/material.dart'; // Importa o pacote de widgets do Flutter
import 'package:firebase_auth/firebase_auth.dart'; // Importa o pacote do Firebase para autenticação
import 'package:quick_read/create-user.dart'; // Importa a tela de criação de usuário
import 'package:quick_read/resumo.dart'; // Importa a tela de resumo
import 'package:quick_read/degrade.dart'; // Importa o Container com o degrade de fundo

// Define a página de login como um widget com estado
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() =>
      _LoginPageState(); // Cria o estado da página de login
}

// Classe que gerencia o estado da página de login
class _LoginPageState extends State<LoginPage> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de e-mail e senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instância do Firebase Authentication
  final _auth = FirebaseAuth.instance;

  // Variável para controlar o estado de carregamento (ao fazer login)
  bool _isLoading = false;

  // Função que lida com o login do usuário
  Future<void> _handleLogin(BuildContext context) async {
    // Verifica se o formulário é válido
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Ativa o estado de carregamento
      });
      try {
        final email = _emailController.text.trim(); // Obtém o e-mail digitado
        final password =
            _passwordController.text.trim(); // Obtém a senha digitada

        // Tenta fazer login com e-mail e senha usando o Firebase
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        // Se o login for bem-sucedido, redireciona para a página de resumo
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ResumoPage()));
      } on FirebaseAuthException catch (e) {
        // Exibe uma mensagem de erro se o login falhar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: ${e.message}'),
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

  // Função que redireciona para a página de criação de usuário
  Future<void> _handleCreateUser(BuildContext context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => CreateUserPage()));
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o usuário já está autenticado
    if (_auth.currentUser != null) {
      print(_auth
          .currentUser?.email); // Exibe o e-mail do usuário logado no console
      print(_auth.currentUser
          ?.displayName); // Exibe o nome do usuário logado no console
      return ResumoPage(); // Se já estiver logado, vai diretamente para a página de resumo
    } else {
      // Se o usuário não estiver autenticado, exibe a tela de login
      return Material(
        child: GradientContainer(
          child: Scaffold(
            backgroundColor:
                Colors.transparent, // Torna o fundo do Scaffold transparente
            appBar: AppBar(
              title: Text('QUICK READ'), // Define o título na AppBar
            ),
            body: SafeArea(
              child: Container(
                margin: EdgeInsets.all(16), // Margem em torno do conteúdo
                child: Form(
                  key:
                      _formKey, // Associa o formulário à chave GlobalKey para validação
                  child: Column(
                    children: [
                      // Campo de texto para o e-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType
                            .emailAddress, // Define o tipo de teclado para e-mail
                        decoration: InputDecoration(
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
                      SizedBox(height: 16), // Espaço vertical entre os campos

                      // Campo de texto para a senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText:
                            true, // Oculta o texto ao digitar (para senhas)
                        decoration: InputDecoration(
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
                      SizedBox(height: 32), // Espaço maior antes dos botões

                      // Linha com botões de "Entrar" e "Criar Conta"
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botão de "Entrar"
                          Expanded(
                            flex: 5,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null // Desabilita o botão se estiver carregando
                                  : () => _handleLogin(
                                      context), // Chama a função de login
                              child: _isLoading
                                  ? CircularProgressIndicator() // Exibe um indicador de carregamento
                                  : Text('ENTRAR'), // Texto do botão
                            ),
                          ),
                          SizedBox(
                            width: 20, // Espaço entre os dois botões
                          ),
                          // Botão de "Criar Conta"
                          Expanded(
                            flex: 5,
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null // Desabilita o botão se estiver carregando
                                  : () => _handleCreateUser(
                                      context), // Chama a função de criação de usuário
                              child: _isLoading
                                  ? CircularProgressIndicator
                                      .adaptive() // Exibe um indicador de carregamento
                                  : Text('CRIAR CONTA'), // Texto do botão
                            ),
                          ),
                        ],
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
