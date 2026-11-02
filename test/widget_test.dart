import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/movie_log_app.dart';

void main() {
  testWidgets('MovieLogApp 기본 위젯 렌더링 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('영화의 순간을 기록하세요'), findsOneWidget);
  });
}