import 'package:flutter_test/flutter_test.dart';
import 'package:vacismart_mobile/main.dart';

void main() {
  testWidgets('Renderiza a tela inicial de login do VaciSmart', (WidgetTester tester) async {
    // Carrega o aplicativo principal
    await tester.pumpWidget(const VaciSmartApp());

    // Verifica se o título VaciSmart e o botão Entrar aparecem na tela
    expect(find.text('VaciSmart'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}