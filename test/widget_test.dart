import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade_forms/main.dart';

void main() {
  // Encontra o TextFormField pelo labelText
  Finder campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

  // Rola até o botão CADASTRAR e clica nele
  Future<void> clicarCadastrar(WidgetTester tester) async {
    await tester.ensureVisible(find.text('CADASTRAR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CADASTRAR'));
    await tester.pump();
  }

  Future<void> preencherValido(WidgetTester tester) async {
    await tester.enterText(campo('Nome completo'), 'Maria da Silva');
    await tester.enterText(campo('E-mail'), 'maria.silva@email.com');
    await tester.enterText(campo('CPF'), '12345678909');
    await tester.enterText(campo('Telefone'), '61991234567');
    await tester.enterText(campo('Senha'), 'flutter123');
    await tester.enterText(campo('Confirmar senha'), 'flutter123');
  }

  testWidgets('formulário vazio mostra erro em todos os campos', (
    tester,
  ) async {
    await tester.pumpWidget(const MeuApp());
    await clicarCadastrar(tester);

    expect(find.text('Digite seu nome completo'), findsOneWidget);
    expect(find.text('Digite seu e-mail'), findsOneWidget);
    expect(find.text('Digite seu CPF'), findsOneWidget);
    expect(find.text('Digite seu telefone'), findsOneWidget);
    expect(find.text('Digite uma senha'), findsOneWidget);
    expect(find.text('Confirme sua senha'), findsOneWidget);
    expect(
      find.text('Corrija os campos em vermelho antes de continuar.'),
      findsOneWidget,
    );
  });

  testWidgets('CPF e telefone aceitam apenas números', (tester) async {
    await tester.pumpWidget(const MeuApp());

    await tester.enterText(campo('CPF'), 'abc123.456.789-09999');
    await tester.enterText(campo('Telefone'), '(61) 99123-4567');

    expect(find.text('12345678909'), findsOneWidget); // máximo de 11 dígitos
    expect(find.text('61991234567'), findsOneWidget);
  });

  testWidgets('valores inválidos mostram a regra que falhou', (tester) async {
    await tester.pumpWidget(const MeuApp());

    await tester.enterText(campo('Nome completo'), 'Maria');
    await tester.enterText(campo('E-mail'), 'maria.email.com');
    await tester.enterText(campo('CPF'), '123456');
    await tester.enterText(campo('Telefone'), '6199');
    await tester.enterText(campo('Senha'), '123');
    await tester.enterText(campo('Confirmar senha'), '1234');
    await clicarCadastrar(tester);

    expect(find.text('Digite nome e sobrenome'), findsOneWidget);
    expect(find.text('O e-mail deve conter @'), findsOneWidget);
    expect(find.text('O CPF deve ter 11 dígitos'), findsOneWidget);
    expect(find.text('Digite DDD + número (10 ou 11 dígitos)'), findsOneWidget);
    expect(
      find.text('A senha deve possuir pelo menos 6 caracteres'),
      findsOneWidget,
    );
    expect(find.text('As senhas não coincidem'), findsOneWidget);
  });

  testWidgets('e-mail com @ mas formato errado é recusado', (tester) async {
    await tester.pumpWidget(const MeuApp());
    await preencherValido(tester);
    await tester.enterText(campo('E-mail'), 'maria@email');
    await clicarCadastrar(tester);

    expect(find.text('Digite um e-mail válido'), findsOneWidget);
  });

  testWidgets('cadastro válido mostra SnackBar de sucesso', (tester) async {
    await tester.pumpWidget(const MeuApp());
    await preencherValido(tester);
    await clicarCadastrar(tester);

    expect(
      find.text('Cadastro de Maria realizado com sucesso!'),
      findsOneWidget,
    );
  });

  testWidgets('botão do olho mostra e oculta a senha', (tester) async {
    await tester.pumpWidget(const MeuApp());

    EditableText senha() => tester.widget<EditableText>(
      find.descendant(of: campo('Senha'), matching: find.byType(EditableText)),
    );

    expect(senha().obscureText, isTrue);
    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();
    expect(senha().obscureText, isFalse);
  });
}
