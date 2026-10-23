import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:el_faro_de_los_dos/main.dart';
import 'package:el_faro_de_los_dos/game_state.dart';

void main() {
  Future<GameController> setup(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final game = GameController(await SharedPreferences.getInstance());
    await tester.pumpWidget(FaroApp(game: game));
    await tester.pumpAndSettle();
    return game;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('title and instructions work without an account', (tester) async {
    await setup(tester);
    expect(find.text('El Faro\nde los Dos'), findsOneWidget);
    expect(find.text('Entrar al faro'), findsOneWidget);
    await tester.tap(find.text('Cómo jugar'));
    await tester.pumpAndSettle();
    expect(find.text('Un móvil, dos personas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full adventure can be completed through actual controls', (
    tester,
  ) async {
    final game = await setup(tester);
    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('dismiss-intro')));
    expect(find.text('El umbral'), findsOneWidget);
    // Read and save the first physical clue.
    await tapVisible(tester, find.byKey(const Key('door_note')));
    expect(game.notes, contains('door_note'));
    await tester.tap(find.text('Volver a la sala'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('solve-puzzle')));
    expect(game.solved[0], isFalse);
    for (int i = 0; i < 3; i++) {
      for (int n = 0; n < GameController.symbolSolution[i]; n++) {
        await tapVisible(tester, find.byKey(Key('dial-$i')));
      }
    }
    await tapVisible(tester, find.byKey(const Key('solve-puzzle')));
    expect(game.solved[0], isTrue);
    await tapVisible(tester, find.byKey(const Key('next-room')));
    expect(game.room, 1);
    for (final d in GameController.routeSolution) {
      await tapVisible(tester, find.byKey(Key('direction-$d')));
    }
    await tapVisible(tester, find.byKey(const Key('solve-puzzle')));
    expect(game.solved[1], isTrue);
    await tapVisible(tester, find.byKey(const Key('next-room')));
    expect(game.room, 2);
    for (int i = 0; i < 3; i++) {
      for (int n = 1; n < GameController.lightSolution[i]; n++) {
        await tapVisible(tester, find.byKey(Key('light-$i-plus')));
      }
    }
    await tapVisible(tester, find.byKey(const Key('solve-puzzle')));
    expect(game.completed, isTrue);
    expect(find.text('La luz vuelve.\nGracias a los dos.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await game.saved;
  });

  testWidgets('small Android screen has no layout overflow', (tester) async {
    await setup(tester, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('dismiss-intro')));
    await tapVisible(tester, find.byKey(const Key('solve-puzzle')));
    expect(tester.takeException(), isNull);
  });
}
