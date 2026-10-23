import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:el_faro_de_los_dos/game_state.dart';

void main() {
  late GameController game;
  late SharedPreferences preferences;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    game = GameController(preferences);
  });

  tearDown(() async {
    await game.saved;
  });

  void solveDoor() {
    for (int i = 0; i < 3; i++) {
      for (int n = 0; n < GameController.symbolSolution[i]; n++) {
        game.cycleSymbol(i);
      }
    }
    expect(game.trySolve(0), isTrue);
  }

  void solveChart() {
    for (final direction in GameController.routeSolution) {
      game.addDirection(direction);
    }
    expect(game.trySolve(1), isTrue);
  }

  test('a new installation has no progress', () {
    expect(game.started, isFalse);
    expect(game.solvedCount, 0);
    expect(game.completed, isFalse);
  });
  test('rooms cannot be skipped, including before starting', () {
    expect(game.trySolve(0), isFalse);
    expect(game.openRoom(1), isFalse);
    game.newGame();
    expect(game.openRoom(2), isFalse);
    expect(game.trySolve(2), isFalse);
    expect(game.openRoom(-1), isFalse);
  });
  test('wrong combination never gives a key', () {
    game.newGame();
    expect(game.trySolve(0), isFalse);
    expect(game.solved[0], isFalse);
    expect(game.unlockedRoom, 0);
  });
  test('symbol dials wrap in both directions', () {
    game.newGame();
    game.cycleSymbol(0, -1);
    expect(game.dials[0], 4);
    game.cycleSymbol(0);
    expect(game.dials[0], 0);
  });
  test('door awards a key and unlocks the chart room', () {
    game.newGame();
    solveDoor();
    expect(game.openRoom(1), isTrue);
    expect(game.openRoom(2), isFalse);
    expect(game.solvedCount, 1);
    game.cycleSymbol(0);
    expect(game.dials, GameController.symbolSolution);
  });
  test('compass has four positions and supports undo and clear', () {
    game.newGame();
    solveDoor();
    for (final d in ['N', 'E', 'S', 'O', 'N']) {
      game.addDirection(d);
    }
    expect(game.route.length, 4);
    game.undoDirection();
    expect(game.route.length, 3);
    game.clearRoute();
    expect(game.route, isEmpty);
    game.addDirection('INVALID');
    expect(game.route, isEmpty);
  });
  test('only the correct route opens the second room', () {
    game.newGame();
    solveDoor();
    for (final d in ['S', 'S', 'N', 'O']) {
      game.addDirection(d);
    }
    expect(game.trySolve(1), isFalse);
    game.clearRoute();
    solveChart();
    expect(game.openRoom(2), isTrue);
    expect(game.solvedCount, 2);
  });
  test('light adjustments stay within one and five', () {
    game.newGame();
    game.adjustLight(0, -20);
    expect(game.light[0], 1);
    game.adjustLight(0, 20);
    expect(game.light[0], 5);
  });
  test('complete adventure requires all three correct mechanisms', () {
    game.newGame();
    solveDoor();
    solveChart();
    expect(game.trySolve(2), isFalse);
    for (int i = 0; i < 3; i++) {
      game.adjustLight(i, GameController.lightSolution[i] - 1);
    }
    expect(game.trySolve(2), isTrue);
    expect(game.completed, isTrue);
    expect(game.finishedAt, isNotNull);
  });
  test('clues are unique and unknown IDs are ignored', () {
    game.newGame();
    game.inspect('door_note');
    game.inspect('door_note');
    game.inspect('fake');
    expect(game.notes, {'door_note'});
  });
  test('hints are optional, capped at three and do not unlock rooms', () {
    game.newGame();
    for (int i = 0; i < 10; i++) {
      game.revealHint(0);
    }
    game.revealHint(2);
    expect(game.hints, [3, 0, 0]);
    expect(game.hintsUsed, 3);
    expect(game.solvedCount, 0);
  });
  test('all progress including partial inputs survives a reload', () async {
    game.newGame();
    solveDoor();
    game.openRoom(1);
    game.addDirection('N');
    game.addDirection('E');
    game.inspect('chart_log');
    game.revealHint(1);
    game.swapRoles();
    await game.saved;
    final restored = GameController(preferences);
    expect(restored.started, isTrue);
    expect(restored.room, 1);
    expect(restored.route, ['N', 'E']);
    expect(restored.notes, {'chart_log'});
    expect(restored.hints, [0, 1, 0]);
    expect(restored.observer, 1);
  });
  test('reset removes the old adventure and partial inputs', () {
    game.newGame();
    solveDoor();
    game.inspect('door_note');
    game.revealHint(0);
    game.newGame();
    expect(game.solvedCount, 0);
    expect(game.room, 0);
    expect(game.notes, isEmpty);
    expect(game.hintsUsed, 0);
    expect(game.dials, [0, 0, 0]);
  });
  test('corrupt save is ignored without crashing', () async {
    await preferences.setString(GameController.storageKey, 'not valid json');
    expect(GameController(preferences).started, isFalse);
  });
  test('impossible save is normalized to valid sequential progress', () async {
    await preferences.setString(
      GameController.storageKey,
      jsonEncode({
        'version': 1,
        'started': true,
        'solved': [false, true, true],
        'room': 99,
        'dials': [-5, 100, 1],
        'light': [0, 6, 2],
        'hints': [99, -1, 1],
        'route': ['N', 'bad', 'E', 'S', 'O', 'N'],
        'notes': ['fake', 'door_note'],
      }),
    );
    final restored = GameController(preferences);
    expect(restored.solved, [false, false, false]);
    expect(restored.room, 0);
    expect(restored.dials, [0, 4, 1]);
    expect(restored.light, [1, 5, 2]);
    expect(restored.hints, [3, 0, 1]);
    expect(restored.route, ['N', 'E', 'S', 'O']);
    expect(restored.notes, {'door_note'});
  });
}
