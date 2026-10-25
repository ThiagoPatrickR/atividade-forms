import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FilteringTextInputFormatter e LengthLimitingTextInputFormatter

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Usuário',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
      ),
      home: const CadastroPage(),
    );
  }
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  // Chave que dá acesso ao estado do Form (usada para chamar validate())
  final _formKey = GlobalKey<FormState>();

  // Controllers: conectam cada campo ao código para ler o valor digitado
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  // Desafio: controla se a senha aparece ou fica oculta
  bool _ocultarSenha = true;
  bool _ocultarConfirmacao = true;

  // Começa sem validar enquanto digita; depois do primeiro clique em
  // CADASTRAR com erro, passa a validar em tempo real
  AutovalidateMode _modoValidacao = AutovalidateMode.disabled;

  // Desafio: validação de e-mail mais robusta com RegExp
  final _emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

  @override
  void dispose() {
    // Libera a memória dos controllers quando a tela é destruída
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // ---------- Validators: retornam a mensagem de erro ou null se for válido ----------

  String? _validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu nome completo';
    }
    if (!value.trim().contains(' ')) {
      return 'Digite nome e sobrenome';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu e-mail';
    }
    if (!value.contains('@')) {
      return 'O e-mail deve conter @';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  String? _validarCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu CPF';
    }
    if (value.length != 11) {
      return 'O CPF deve ter 11 dígitos';
    }
    return null;
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu telefone';
    }
    if (value.length < 10) {
      return 'Digite DDD + número (10 ou 11 dígitos)';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve possuir pelo menos 6 caracteres';
    }
    return null;
  }

  // Desafio: confirmação de senha
  String? _validarConfirmacao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _senhaController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  // ---------- Ação do botão CADASTRAR ----------

  void _cadastrar() {
    // Remove o SnackBar anterior para não acumular mensagens
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // validate() executa o validator de todos os TextFormField do Form
    if (_formKey.currentState!.validate()) {
      String primeiroNome = _nomeController.text.trim().split(' ').first;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro de $primeiroNome realizado com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } else {
      setState(() {
        _modoValidacao = AutovalidateMode.onUserInteraction;
      });

      // Desafio: SnackBar de erro em vermelho
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrija os campos em vermelho antes de continuar.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _modoValidacao,
        child: SingleChildScrollView(
          // Padding ao redor do formulário (margens laterais)
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome completo: texto livre, sem números
              TextFormField(
                controller: _nomeController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  hintText: 'Ex.: Maria da Silva',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: _validarNome,
              ),
              const SizedBox(height: 16),

              // E-mail: teclado de e-mail e sem espaços
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'Ex.: maria@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: _validarEmail,
              ),
              const SizedBox(height: 16),

              // CPF: teclado numérico, só dígitos, no máximo 11
              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: 'Somente números (11 dígitos)',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: _validarCpf,
              ),
              const SizedBox(height: 16),

              // Telefone: teclado de telefone, só dígitos, DDD + número
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'DDD + número, só números',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: _validarTelefone,
              ),
              const SizedBox(height: 16),

              // Senha: oculta por padrão, com botão para mostrar/ocultar
              TextFormField(
                controller: _senhaController,
                obscureText: _ocultarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Mínimo de 6 caracteres',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                    icon: Icon(
                      _ocultarSenha ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarSenha = !_ocultarSenha;
                      });
                    },
                  ),
                ),
                validator: _validarSenha,
              ),
              const SizedBox(height: 16),

              // Desafio: confirmação de senha
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: _ocultarConfirmacao,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                  hintText: 'Digite a senha novamente',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _ocultarConfirmacao
                        ? 'Mostrar confirmação'
                        : 'Ocultar confirmação',
                    icon: Icon(
                      _ocultarConfirmacao
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarConfirmacao = !_ocultarConfirmacao;
                      });
                    },
                  ),
                ),
                validator: _validarConfirmacao,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _cadastrar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'CADASTRAR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
