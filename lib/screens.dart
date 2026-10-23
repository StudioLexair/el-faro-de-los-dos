import 'package:flutter/material.dart';
import 'content.dart';
import 'game_state.dart';
import 'faro_widgets.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.game});
  final GameController game;

  Future<void> _enter(BuildContext context, {bool fresh = false}) async {
    if (fresh && game.started) {
      final confirmed = await showFaroSheet<bool>(
        context,
        title: '¿Un nuevo comienzo?',
        eyebrow: 'LA PARTIDA ACTUAL SE REEMPLAZARÁ',
        builder: (ctx) => Column(
          children: [
            const Text(
              'Vuestra aventura está guardada en este móvil. Empezar de nuevo borrará ese progreso.',
              style: TextStyle(
                fontSize: 13,
                height: 1.8,
                color: FaroColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            GoldButton(
              'Sí, empezar de nuevo',
              onPressed: () => Navigator.pop(ctx, true),
            ),
            QuietButton(
              'Conservar mi partida',
              onPressed: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    final isNew = fresh || !game.started;
    if (isNew) game.newGame();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => game.completed
            ? EndingScreen(game: game)
            : GameScreen(game: game, showIntro: isNew),
      ),
    );
  }

  void _howTo(BuildContext context) => showFaroSheet(
    context,
    title: 'Dos miradas. Una luz.',
    eyebrow: 'CÓMO JUGAR',
    builder: (_) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _instruction(
          Icons.people_outline_rounded,
          'Un móvil, dos personas',
          'Sentaos juntos. Una persona observa los objetos y la otra conecta las pistas. Intercambiad los papeles cuando queráis.',
        ),
        _instruction(
          Icons.touch_app_outlined,
          'Explorad las pequeñas luces',
          'Tocad los círculos dorados de cada sala. Las notas que descubráis se guardan en vuestro cuaderno.',
        ),
        _instruction(
          Icons.extension_outlined,
          'Hablad antes de probar',
          'Resolved tres mecanismos para llegar a la cima. No hay reloj, vidas ni penalizaciones.',
        ),
        _instruction(
          Icons.lightbulb_outline_rounded,
          'Siempre hay otra pista',
          'Cada sala tiene tres ayudas opcionales. La última revela la solución si queréis seguir avanzando.',
        ),
        const Divider(color: FaroColors.border),
        const SizedBox(height: 10),
        const Text(
          'Partida local y sin conexión. El progreso se guarda automáticamente en este dispositivo. No hay cuentas, anuncios, compras ni servicios externos.',
          style: TextStyle(fontSize: 11, color: FaroColors.muted, height: 1.9),
        ),
      ],
    ),
  );

  Widget _instruction(IconData icon, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: FaroColors.gold, size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.8,
                  color: FaroColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: game,
    builder: (context, _) => Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 720;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/art/island.webp',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -.03),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .34, .57, .78, 1],
                    colors: [
                      Color(0xEB081B25),
                      Color(0x18081B25),
                      Color(0x00081B25),
                      Color(0xC0081B25),
                      Color(0xFF081B25),
                    ],
                  ),
                ),
              ),
              const IgnorePointer(child: CustomPaint(painter: StarsPainter())),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: Column(
                    children: [
                      SizedBox(height: compact ? 26 : 41),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_awesome_outlined,
                            color: FaroColors.gold,
                            size: 13,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'UNA AVENTURA PARA DOS',
                            style: labelStyle(size: 8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 21),
                      Text(
                        'El Faro\nde los Dos',
                        textAlign: TextAlign.center,
                        style: titleStyle(
                          compact ? 60 : 70,
                        ).copyWith(letterSpacing: -1.8, height: .92),
                      ),
                      const SizedBox(height: 18),
                      const Ornament(width: 92),
                      const SizedBox(height: 12),
                      Text(
                        'Cada pista nos acerca.',
                        style: TextStyle(
                          fontSize: compact ? 11 : 12,
                          color: FaroColors.cream.withValues(alpha: .75),
                          letterSpacing: .5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: FaroColors.night.withValues(alpha: .6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'COOPERATIVO   ·   1 MÓVIL   ·   SIN INTERNET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 1.05,
                            color: FaroColors.paleGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      GoldButton(
                        game.completed
                            ? 'Contemplar nuestra luz'
                            : (game.started
                                  ? 'Continuar la aventura'
                                  : 'Entrar al faro'),
                        key: const Key('start-game'),
                        onPressed: () => _enter(context),
                      ),
                      if (game.started) ...[
                        const SizedBox(height: 4),
                        QuietButton(
                          'Empezar de nuevo',
                          onPressed: () => _enter(context, fresh: true),
                        ),
                      ],
                      if (!game.started) const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          QuietButton(
                            'Cómo jugar',
                            icon: Icons.help_outline_rounded,
                            onPressed: () => _howTo(context),
                          ),
                          const Text(
                            '·',
                            style: TextStyle(color: FaroColors.border),
                          ),
                          Text(
                            'Capítulo I',
                            style: labelStyle(size: 8, color: FaroColors.muted),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 18),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.game, this.showIntro = false});
  final GameController game;
  final bool showIntro;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _scroll = ScrollController();
  final _puzzleKey = GlobalKey();
  String _feedback = '';
  int _lastRoom = -1;
  GameController get game => widget.game;

  @override
  void initState() {
    super.initState();
    if (widget.showIntro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _intro();
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _intro() => showFaroSheet(
    context,
    title: 'La última guardiana',
    eyebrow: 'UN MENSAJE DE ADA',
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '«Si estáis leyendo esto, la luz se ha apagado.\n\nNo dejé una solución. Dejé dos formas de mirar. La isla necesita a alguien que observe y a alguien que conecte.\n\nSubid juntos. El mar os está esperando.»',
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 24,
            height: 1.5,
            color: FaroColors.cream,
          ),
        ),
        const SizedBox(height: 26),
        GoldButton(
          'Empezamos juntos',
          key: const Key('dismiss-intro'),
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );

  void _inspect(String id) {
    touch();
    game.inspect(id);
    final clue = clues[id]!;
    showFaroSheet(
      context,
      title: clue.title,
      eyebrow: 'PISTA AÑADIDA AL CUADERNO',
      builder: (ctx) => Column(
        children: [
          PaperClue(clue),
          const SizedBox(height: 18),
          QuietButton(
            'Volver a la sala',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _focusPuzzle() {
    touch();
    final target = _puzzleKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: .08,
      );
    }
  }

  void _journal() => showFaroSheet(
    context,
    title: 'Nuestro cuaderno',
    eyebrow: 'PISTAS QUE ENCONTRASTEIS',
    builder: (_) => AnimatedBuilder(
      animation: game,
      builder: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${game.notes.length} de 6 notas descubiertas',
            style: const TextStyle(color: FaroColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 20),
          if (game.notes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 26),
              child: Text(
                'Todavía no habéis abierto ninguna nota. Tocad los círculos dorados sobre los objetos de la sala.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.8,
                  color: FaroColors.muted,
                ),
              ),
            ),
          for (final clue in clues.values.where(
            (c) => game.notes.contains(c.id),
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: FaroColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  iconColor: FaroColors.gold,
                  collapsedIconColor: FaroColors.gold,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    clue.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: FaroColors.cream,
                    ),
                  ),
                  subtitle: Text(
                    clue.subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: FaroColors.muted,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: [PaperClue(clue)],
                ),
              ),
            ),
        ],
      ),
    ),
  );

  void _map() => showFaroSheet(
    context,
    title: 'El camino hacia la luz',
    eyebrow: 'LAS TRES SALAS',
    builder: (ctx) => Column(
      children: List.generate(3, (i) {
        final locked = i > game.unlockedRoom;
        final selected = i == game.room;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: locked
                ? null
                : () {
                    Navigator.pop(ctx);
                    _goToRoom(i);
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: selected ? FaroColors.teal : FaroColors.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? FaroColors.gold : FaroColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : (game.solved[i]
                              ? Icons.check_circle_outline_rounded
                              : Icons.door_front_door_outlined),
                    color: locked ? FaroColors.muted : FaroColors.gold,
                    size: 24,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rooms[i].title,
                          style: titleStyle(
                            25,
                            color: locked ? FaroColors.muted : FaroColors.cream,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          locked
                              ? 'Abrid el mecanismo anterior'
                              : (game.solved[i]
                                    ? 'Mecanismo resuelto'
                                    : 'Os espera una pista'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: FaroColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!locked)
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: FaroColors.gold,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );

  void _goToRoom(int index) {
    if (!game.openRoom(index)) return;
    _feedback = '';
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _hints() {
    final index = game.room;
    showFaroSheet(
      context,
      title: 'Una pequeña luz',
      eyebrow: 'AYUDAS SIN PENALIZACIÓN',
      builder: (_) => AnimatedBuilder(
        animation: game,
        builder: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A vuestro ritmo. Abrid solo la ayuda que necesitéis; la tercera revela la solución.',
              style: TextStyle(
                fontSize: 12,
                height: 1.8,
                color: FaroColors.muted,
              ),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < game.hints[index]; i++)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: FaroColors.panel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FaroColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PISTA ${i + 1}', style: labelStyle(size: 8)),
                    const SizedBox(height: 10),
                    Text(
                      rooms[index].hints[i],
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.8,
                        color: FaroColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (game.hints[index] < 3)
              GoldButton(
                game.hints[index] == 0
                    ? 'Abrir la primera pista'
                    : (game.hints[index] == 2
                          ? 'Ver la solución'
                          : 'Abrir otra pista'),
                icon: Icons.lightbulb_outline_rounded,
                onPressed: () => game.revealHint(index),
              ),
            if (game.hints[index] == 3)
              const Text(
                'Ya tenéis todas las pistas de esta sala.',
                style: TextStyle(fontSize: 11, color: FaroColors.muted),
              ),
          ],
        ),
      ),
    );
  }

  void _inventory(int index) {
    final has = game.solved[index];
    final titles = ['Llave de latón', 'Lente de cristal', 'La luz del faro'];
    final descriptions = [
      'Una llave pequeña y cálida. Abre la escalera de la sala de cartas; la usáis automáticamente al subir.',
      'Una lente que guarda reflejos del mar. Se coloca automáticamente en el mecanismo de la linterna.',
      'No todo lo que encontráis cabe en un bolsillo. Esta luz pertenece a los dos.',
    ];
    showFaroSheet(
      context,
      title: has ? titles[index] : 'Un hallazgo por descubrir',
      eyebrow: 'VUESTRO INVENTARIO',
      builder: (_) => Text(
        has
            ? descriptions[index]
            : 'Seguid explorando y resolved el mecanismo de la sala ${index + 1}. Su hallazgo aparecerá aquí.',
        style: const TextStyle(
          fontSize: 13,
          color: FaroColors.muted,
          height: 1.9,
        ),
      ),
    );
  }

  Future<void> _solve() async {
    touch();
    final room = game.room;
    if (!game.trySolve(room)) {
      setState(() {
        _feedback = switch (room) {
          0 => 'Los discos aún no encajan. ¿Qué decía la nota del banco?',
          1 =>
            game.route.length < 4
                ? 'Necesitáis las cuatro direcciones del viaje.'
                : 'La brújula no reconoce esa ruta. Volved al cuaderno de navegación.',
          _ =>
            'La luz tiembla, pero aún no despierta. Comparad la postal con la calibración.',
        };
      });
      return;
    }
    setState(() => _feedback = '');
    if (room == 2) {
      await game.saved;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => EndingScreen(game: game)),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusPuzzle();
      });
    }
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 5, 12, 9),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              tooltip: 'Volver a la portada. Partida guardada.',
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: FaroColors.gold,
                size: 20,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'EL FARO DE LOS DOS',
                    textAlign: TextAlign.center,
                    style: labelStyle(size: 8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${game.solvedCount} DE 3 MECANISMOS',
                    style: labelStyle(color: FaroColors.muted, size: 7),
                  ),
                ],
              ),
            ),
            RoundAction(
              Icons.map_outlined,
              label: 'Mapa de las salas',
              onPressed: _map,
            ),
            const SizedBox(width: 4),
            RoundAction(
              Icons.auto_stories_outlined,
              label: 'Abrir nuestro cuaderno',
              badge: game.notes.isEmpty ? null : '${game.notes.length}',
              onPressed: _journal,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                  color: game.solved[i]
                      ? FaroColors.gold
                      : (game.room == i
                            ? const Color(0xFF6A684E)
                            : FaroColors.border),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _scene() => AspectRatio(
    aspectRatio: 4 / 3,
    child: LayoutBuilder(
      builder: (context, bounds) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(rooms[game.room].art, fit: BoxFit.cover),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55081B25),
                    Color(0x00081B25),
                    Color(0xD9081B25),
                  ],
                  stops: [0, .45, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: 11,
            left: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: FaroColors.night.withValues(alpha: .78),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'TOCAD LAS LUCES PARA EXPLORAR',
                style: labelStyle(size: 7, color: FaroColors.paleGold),
              ),
            ),
          ),
          for (final point in rooms[game.room].hotspots)
            Positioned(
              left: bounds.maxWidth * point.x - 22,
              top: bounds.maxHeight * point.y - 22,
              child: Semantics(
                button: true,
                label: point.label,
                child: Tooltip(
                  message: point.label,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: Key(point.clue ?? 'puzzle-hotspot-${game.room}'),
                      onTap: point.clue != null
                          ? () => _inspect(point.clue!)
                          : _focusPuzzle,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: FaroColors.night.withValues(alpha: .82),
                          border: Border.all(
                            color: FaroColors.gold,
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FaroColors.gold.withValues(alpha: .23),
                              blurRadius: 17,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            point.clue != null &&
                                    game.notes.contains(point.clue)
                                ? Icons.check_rounded
                                : point.icon,
                            color: FaroColors.paleGold,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _roleBar() => Container(
    margin: const EdgeInsets.fromLTRB(22, 4, 22, 20),
    padding: const EdgeInsets.only(left: 13, right: 3),
    decoration: BoxDecoration(
      color: FaroColors.panel.withValues(alpha: .6),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: FaroColors.border),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.people_outline_rounded,
          size: 17,
          color: FaroColors.gold,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'Guía: Mirada ${game.observer + 1}',
            style: const TextStyle(fontSize: 11, color: FaroColors.muted),
          ),
        ),
        QuietButton(
          'Cambiar',
          icon: Icons.swap_horiz_rounded,
          onPressed: () {
            touch();
            game.swapRoles();
          },
        ),
      ],
    ),
  );

  Widget _puzzle() {
    final index = game.room;
    final data = rooms[index];
    return Container(
      key: _puzzleKey,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FaroColors.panel, Color(0xFF102830)],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: FaroColors.border),
      ),
      child: game.solved[index]
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: FaroColors.green,
                  size: 29,
                ),
                const SizedBox(height: 14),
                Text(data.successTitle, style: titleStyle(32)),
                const SizedBox(height: 13),
                Text(
                  data.successBody,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.8,
                    color: FaroColors.muted,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 15,
                      color: FaroColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.reward,
                      style: const TextStyle(
                        fontSize: 12,
                        color: FaroColors.paleGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (index < 2)
                  GoldButton(
                    index == 0
                        ? 'Subir a la sala de cartas'
                        : 'Subir a la linterna',
                    key: const Key('next-room'),
                    onPressed: () {
                      touch();
                      game.swapRoles();
                      _goToRoom(index + 1);
                    },
                  ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EL MECANISMO', style: labelStyle(size: 8)),
                const SizedBox(height: 12),
                Text(data.puzzleTitle, style: titleStyle(32)),
                const SizedBox(height: 9),
                Text(
                  data.puzzleSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.7,
                    color: FaroColors.muted,
                  ),
                ),
                const SizedBox(height: 27),
                if (index == 0) ...[
                  Row(
                    children: List.generate(
                      3,
                      (i) => SymbolDial(
                        index: i,
                        value: game.dials[i],
                        onTap: () {
                          touch();
                          game.cycleSymbol(i);
                          setState(() => _feedback = '');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                if (index == 1) ...[
                  Center(child: CompassPuzzle(game: game)),
                  const SizedBox(height: 13),
                ],
                if (index == 2) ...[
                  Row(
                    children: List.generate(
                      3,
                      (i) => LightDial(
                        index: i,
                        value: game.light[i],
                        onAdjust: (delta) {
                          touch();
                          game.adjustLight(i, delta);
                          setState(() => _feedback = '');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_feedback.isNotEmpty)
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 17),
                      decoration: BoxDecoration(
                        color: FaroColors.gold.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _feedback,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.8,
                          color: FaroColors.paleGold,
                        ),
                      ),
                    ),
                  ),
                GoldButton(
                  data.action,
                  key: const Key('solve-puzzle'),
                  onPressed: _solve,
                  icon: index == 2
                      ? Icons.flare_rounded
                      : Icons.lock_open_rounded,
                ),
              ],
            ),
    );
  }

  Widget _inventoryBar() {
    const icons = [
      Icons.vpn_key_outlined,
      Icons.lens_outlined,
      Icons.flare_rounded,
    ];
    const labels = ['Llave', 'Lente', 'Luz'];
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      decoration: const BoxDecoration(
        color: FaroColors.deep,
        border: Border(top: BorderSide(color: FaroColors.border)),
      ),
      child: Row(
        children: List.generate(
          3,
          (i) => Expanded(
            child: InkWell(
              onTap: () => _inventory(i),
              borderRadius: BorderRadius.circular(9),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: game.solved[i]
                            ? FaroColors.teal
                            : Colors.transparent,
                        border: Border.all(
                          color: game.solved[i]
                              ? FaroColors.gold
                              : FaroColors.border,
                        ),
                      ),
                      child: Icon(
                        game.solved[i] ? icons[i] : Icons.question_mark_rounded,
                        size: 17,
                        color: game.solved[i]
                            ? FaroColors.gold
                            : FaroColors.border,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 9,
                        color: game.solved[i]
                            ? FaroColors.paleGold
                            : FaroColors.muted,
                      ),
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

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: game,
    builder: (context, _) {
      if (_lastRoom != game.room) {
        _feedback = '';
        _lastRoom = game.room;
      }
      final data = rooms[game.room];
      return Scaffold(
        backgroundColor: FaroColors.night,
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.eyebrow, style: labelStyle(size: 8)),
                            const SizedBox(height: 12),
                            Text(data.title, style: titleStyle(44)),
                            const SizedBox(height: 12),
                            Text(
                              data.description,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.8,
                                color: FaroColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _scene(),
                      _roleBar(),
                      _puzzle(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 8, 22, 25),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            QuietButton(
                              'Necesitamos una pista',
                              icon: Icons.lightbulb_outline_rounded,
                              onPressed: _hints,
                            ),
                            Text(
                              '${game.hints[game.room]}/3',
                              style: const TextStyle(
                                fontSize: 9,
                                color: FaroColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _inventoryBar(),
            ],
          ),
        ),
      );
    },
  );
}

class EndingScreen extends StatelessWidget {
  const EndingScreen({super.key, required this.game});
  final GameController game;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/art/island.webp', fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xEE081B25), Color(0x30081B25), Color(0xFF081B25)],
              stops: [0, .4, .86],
            ),
          ),
        ),
        const IgnorePointer(
          child: CustomPaint(painter: StarsPainter(ending: true)),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 31,
                    vertical: 31,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.flare_rounded,
                          size: 32,
                          color: FaroColors.gold,
                        ),
                        const SizedBox(height: 17),
                        Text(
                          'EL FARO HA DESPERTADO',
                          style: labelStyle(size: 8),
                        ),
                        const SizedBox(height: 19),
                        Text(
                          'La luz vuelve.\nGracias a los dos.',
                          textAlign: TextAlign.center,
                          style: titleStyle(53),
                        ),
                        const SizedBox(height: 19),
                        const Ornament(),
                        const Spacer(),
                        const SizedBox(height: 130),
                        const Text(
                          '«Hay luces que solo se encienden\ncuando alguien mira contigo.»',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 25,
                            height: 1.4,
                            color: FaroColors.cream,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            color: FaroColors.deep.withValues(alpha: .85),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: FaroColors.border),
                          ),
                          child: Row(
                            children: [
                              _stat('3', 'MECANISMOS'),
                              _stat('${game.notes.length}/6', 'NOTAS'),
                              _stat('${game.hintsUsed}', 'PISTAS USADAS'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        GoldButton(
                          'Volver a la isla',
                          onPressed: () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                        ),
                        const SizedBox(height: 7),
                        QuietButton(
                          'Jugar de nuevo juntos',
                          icon: Icons.restart_alt_rounded,
                          onPressed: () {
                            game.newGame();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    GameScreen(game: game, showIntro: true),
                              ),
                            );
                          },
                        ),
                        Text(
                          'FIN DEL CAPÍTULO I',
                          style: labelStyle(size: 7, color: FaroColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _stat(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(value, style: titleStyle(29, color: FaroColors.paleGold)),
        const SizedBox(height: 7),
        Text(label, style: labelStyle(size: 6, color: FaroColors.muted)),
      ],
    ),
  );
}
