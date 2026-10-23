import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// All progress is local. No account, server, permissions or personal data.
class GameController extends ChangeNotifier {
  GameController(this.preferences) {
    _restore();
  }

  static const storageKey = 'el_faro_de_los_dos.v1';
  static const symbols = ['Sol', 'Luna', 'Marea', 'Estrella', 'Concha'];
  static const symbolSolution = [1, 2, 3];
  static const routeSolution = ['N', 'E', 'S', 'O'];
  static const lightSolution = [3, 2, 4];
  static const noteIds = {
    'door_note',
    'door_lantern',
    'chart_sky',
    'chart_log',
    'light_observation',
    'light_formula',
  };

  final SharedPreferences preferences;
  bool started = false;
  List<bool> solved = [false, false, false];
  int room = 0;
  int observer = 0;
  List<int> dials = [0, 0, 0];
  List<String> route = [];
  List<int> light = [1, 1, 1];
  List<int> hints = [0, 0, 0];
  Set<String> notes = {};
  DateTime? startedAt;
  DateTime? finishedAt;
  Future<void> _pending = Future.value();

  bool get completed => solved.every((s) => s);
  int get unlockedRoom => solved[1] ? 2 : (solved[0] ? 1 : 0);
  int get solvedCount => solved.where((s) => s).length;
  int get hintsUsed => hints.fold(0, (sum, n) => sum + n);
  Future<void> get saved => _pending;

  void newGame() {
    started = true;
    solved = [false, false, false];
    room = 0;
    observer = 0;
    dials = [0, 0, 0];
    route = [];
    light = [1, 1, 1];
    hints = [0, 0, 0];
    notes = {};
    startedAt = DateTime.now();
    finishedAt = null;
    _changed();
  }

  bool openRoom(int target) {
    if (!started || target < 0 || target > unlockedRoom) return false;
    room = target;
    _changed();
    return true;
  }

  void swapRoles() {
    observer = 1 - observer;
    _changed();
  }

  void inspect(String id) {
    if (noteIds.contains(id) && notes.add(id)) _changed();
  }

  void cycleSymbol(int index, [int delta = 1]) {
    if (index < 0 || index > 2 || solved[0]) return;
    dials[index] = (dials[index] + delta) % symbols.length;
    _changed();
  }

  void addDirection(String direction) {
    if (solved[1] || route.length == 4 || !routeSolution.contains(direction)) {
      return;
    }
    route.add(direction);
    _changed();
  }

  void undoDirection() {
    if (route.isEmpty || solved[1]) return;
    route.removeLast();
    _changed();
  }

  void clearRoute() {
    if (solved[1]) return;
    route.clear();
    _changed();
  }

  void adjustLight(int index, int delta) {
    if (index < 0 || index > 2 || solved[2]) return;
    light[index] = (light[index] + delta).clamp(1, 5);
    _changed();
  }

  bool trySolve(int target) {
    if (!started || target < 0 || target > unlockedRoom) return false;
    if (solved[target]) return true;
    final correct = switch (target) {
      0 => listEquals(dials, symbolSolution),
      1 => listEquals(route, routeSolution),
      2 => listEquals(light, lightSolution),
      _ => false,
    };
    if (!correct) return false;
    solved[target] = true;
    if (target == 2) finishedAt = DateTime.now();
    _changed();
    return true;
  }

  void revealHint(int target) {
    if (target < 0 || target > unlockedRoom || hints[target] >= 3) return;
    hints[target]++;
    _changed();
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'started': started,
    'solved': solved.toList(),
    'room': room,
    'observer': observer,
    'dials': dials.toList(),
    'route': route.toList(),
    'light': light.toList(),
    'hints': hints.toList(),
    'notes': notes.toList(),
    'startedAt': startedAt?.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
  };

  void _changed() {
    final payload = jsonEncode(toJson());
    // Serialize writes so a slower older write cannot overwrite newer progress.
    _pending = _pending.then((_) async {
      try {
        await preferences.setString(storageKey, payload);
      } catch (e) {
        debugPrint('No se pudo guardar la partida: $e');
      }
    });
    notifyListeners();
  }

  void _restore() {
    try {
      final raw = preferences.getString(storageKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['version'] != 1 || map['started'] != true) return;
      List<int> ints(String key, int minimum, int maximum, List<int> fallback) {
        final value = map[key];
        if (value is! List || value.length != 3) return fallback;
        return value
            .map((v) => v is int ? v.clamp(minimum, maximum) : minimum)
            .toList();
      }

      final flags = map['solved'];
      if (flags is! List || flags.length != 3) return;
      final parsed = flags.map((v) => v == true).toList();
      // Normalize impossible/out-of-order or damaged save files.
      parsed[1] = parsed[0] && parsed[1];
      parsed[2] = parsed[1] && parsed[2];
      solved = parsed;
      room = (map['room'] is int ? map['room'] as int : 0).clamp(
        0,
        unlockedRoom,
      );
      observer = map['observer'] == 1 ? 1 : 0;
      dials = ints('dials', 0, 4, [0, 0, 0]);
      light = ints('light', 1, 5, [1, 1, 1]);
      hints = ints('hints', 0, 3, [0, 0, 0]);
      final savedRoute = map['route'];
      route = savedRoute is List
          ? savedRoute
                .whereType<String>()
                .where(routeSolution.contains)
                .take(4)
                .toList()
          : [];
      final savedNotes = map['notes'];
      notes = savedNotes is List
          ? savedNotes.whereType<String>().where(noteIds.contains).toSet()
          : {};
      startedAt = DateTime.tryParse('${map['startedAt']}');
      finishedAt = completed ? DateTime.tryParse('${map['finishedAt']}') : null;
      started = true;
    } catch (_) {
      // Corrupt or outdated data never blocks a new game.
    }
  }
}
