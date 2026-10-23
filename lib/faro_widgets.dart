import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'content.dart';
import 'game_state.dart';

abstract final class FaroColors {
  static const night = Color(0xFF081B25);
  static const deep = Color(0xFF0C242D);
  static const panel = Color(0xFF112F37);
  static const teal = Color(0xFF183F44);
  static const gold = Color(0xFFD6B574);
  static const paleGold = Color(0xFFF0DCAD);
  static const cream = Color(0xFFF4EBD7);
  static const muted = Color(0xFF9AAFAD);
  static const green = Color(0xFF8EBFA8);
  static const border = Color(0xFF29434A);
}

TextStyle titleStyle(double size, {Color color = FaroColors.cream}) =>
    TextStyle(
      fontFamily: 'Cormorant',
      fontSize: size,
      height: 1.02,
      fontWeight: FontWeight.w500,
      color: color,
    );
TextStyle labelStyle({Color color = FaroColors.gold, double size = 9}) =>
    TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
      color: color,
    );

void touch() {
  HapticFeedback.selectionClick();
}

class GoldButton extends StatelessWidget {
  const GoldButton(
    this.text, {
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: FaroColors.gold,
        foregroundColor: FaroColors.deep,
        disabledBackgroundColor: FaroColors.border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 21),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 13),
          Icon(icon, size: 18),
        ],
      ),
    ),
  );
}

class QuietButton extends StatelessWidget {
  const QuietButton(this.text, {super.key, required this.onPressed, this.icon});
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: FaroColors.muted,
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class RoundAction extends StatelessWidget {
  const RoundAction(
    this.icon, {
    super.key,
    required this.label,
    required this.onPressed,
    this.badge,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? badge;
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        onPressed: onPressed,
        tooltip: label,
        style: IconButton.styleFrom(
          foregroundColor: FaroColors.gold,
          backgroundColor: FaroColors.panel.withValues(alpha: .8),
          side: const BorderSide(color: FaroColors.border),
        ),
        icon: Icon(icon, size: 19),
      ),
      if (badge != null)
        Positioned(
          top: 1,
          right: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 15),
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: FaroColors.gold,
              shape: BoxShape.circle,
            ),
            child: Text(
              badge!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: FaroColors.night,
                fontSize: 8,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  );
}

class Ornament extends StatelessWidget {
  const Ornament({super.key, this.width = 110});
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Row(
      children: [
        const Expanded(child: Divider(color: FaroColors.gold, thickness: .5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 5, height: 5, color: FaroColors.gold),
          ),
        ),
        const Expanded(child: Divider(color: FaroColors.gold, thickness: .5)),
      ],
    ),
  );
}

Future<T?> showFaroSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  String? eyebrow,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  barrierColor: Colors.black.withValues(alpha: .75),
  builder: (sheetContext) => Container(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(sheetContext).height * .91,
    ),
    decoration: const BoxDecoration(
      color: FaroColors.deep,
      border: Border(top: BorderSide(color: FaroColors.gold, width: .6)),
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: FaroColors.border,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(height: 19),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null) ...[
                        Text(eyebrow, style: labelStyle()),
                        const SizedBox(height: 10),
                      ],
                      Text(title, style: titleStyle(33)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  tooltip: 'Cerrar',
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: FaroColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            builder(sheetContext),
          ],
        ),
      ),
    ),
  ),
);

class PaperClue extends StatelessWidget {
  const PaperClue(this.clue, {super.key});
  final Clue clue;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: FaroColors.cream,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFD6C6A3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              color: Color(0xFF6D654E),
              size: 17,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                clue.subtitle.toUpperCase(),
                style: labelStyle(color: const Color(0xFF807352), size: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        if (clue.diagram) ...[
          const ObservationDiagram(),
          const SizedBox(height: 20),
        ],
        Text(
          clue.body,
          style: const TextStyle(
            color: Color(0xFF3A463F),
            fontSize: 13,
            height: 1.9,
          ),
        ),
      ],
    ),
  );
}

class ObservationDiagram extends StatelessWidget {
  const ObservationDiagram({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'La postal muestra exactamente tres estrellas y dos ventanas encendidas.',
    child: ExcludeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF173C46),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Icon(
                    Icons.star_rounded,
                    size: i == 1 ? 23 : 17,
                    color: FaroColors.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(width: 40, height: 9, color: FaroColors.gold),
            Container(
              width: 28,
              height: 73,
              decoration: const BoxDecoration(
                color: Color(0xFFC2CEBD),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  2,
                  (_) => Container(
                    width: 8,
                    height: 13,
                    decoration: const BoxDecoration(
                      color: FaroColors.gold,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            const Icon(Icons.waves_rounded, size: 38, color: Color(0xFF71938B)),
          ],
        ),
      ),
    ),
  );
}

class SymbolDial extends StatelessWidget {
  const SymbolDial({
    super.key,
    required this.value,
    required this.index,
    required this.onTap,
  });
  final int value, index;
  final VoidCallback onTap;
  static const icons = [
    Icons.wb_sunny_outlined,
    Icons.nightlight_round,
    Icons.waves_rounded,
    Icons.star_outline_rounded,
    Icons.spa_outlined,
  ];
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text('${index + 1}', style: labelStyle(color: FaroColors.muted)),
        const SizedBox(height: 11),
        Semantics(
          button: true,
          label:
              'Disco ${index + 1}: ${GameController.symbols[value]}. Cambiar símbolo.',
          child: Tooltip(
            message: 'Cambiar símbolo ${index + 1}',
            child: InkWell(
              key: Key('dial-$index'),
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF32504C), Color(0xFF142D34)],
                  ),
                  border: Border.all(
                    color: FaroColors.gold.withValues(alpha: .75),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FaroColors.gold.withValues(alpha: .06),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icons[value],
                    color: FaroColors.paleGold,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          GameController.symbols[value].toUpperCase(),
          style: labelStyle(size: 8),
        ),
        const SizedBox(height: 9),
        const Icon(Icons.touch_app_outlined, size: 15, color: FaroColors.muted),
      ],
    ),
  );
}

class LightDial extends StatelessWidget {
  const LightDial({
    super.key,
    required this.index,
    required this.value,
    required this.onAdjust,
  });
  final int index, value;
  final ValueChanged<int> onAdjust;
  static const labels = ['LÁMPARA', 'LENTE', 'ESPEJO'];
  static const roman = ['I', 'II', 'III', 'IV', 'V'];
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(labels[index], style: labelStyle(size: 8)),
        const SizedBox(height: 13),
        Semantics(
          label: '${labels[index]}, marca $value de 5',
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FaroColors.teal,
              border: Border.all(color: FaroColors.gold.withValues(alpha: .8)),
            ),
            child: Center(
              child: Text(
                roman[value - 1],
                style: titleStyle(34, color: FaroColors.paleGold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 43,
              child: IconButton(
                key: Key('light-$index-minus'),
                tooltip: 'Bajar ${labels[index].toLowerCase()}',
                onPressed: value > 1 ? () => onAdjust(-1) : null,
                icon: const Icon(Icons.remove_rounded, size: 18),
              ),
            ),
            SizedBox(
              width: 36,
              height: 43,
              child: IconButton(
                key: Key('light-$index-plus'),
                tooltip: 'Subir ${labels[index].toLowerCase()}',
                onPressed: value < 5 ? () => onAdjust(1) : null,
                icon: const Icon(Icons.add_rounded, size: 18),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class CompassPuzzle extends StatelessWidget {
  const CompassPuzzle({super.key, required this.game});
  final GameController game;
  Widget direction(String id, IconData icon) => Expanded(
    child: Center(
      child: SizedBox(
        width: 53,
        height: 53,
        child: OutlinedButton(
          key: Key('direction-$id'),
          onPressed: game.route.length < 4
              ? () {
                  touch();
                  game.addDirection(id);
                }
              : null,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: FaroColors.gold,
            side: BorderSide(color: FaroColors.gold.withValues(alpha: .55)),
            shape: const CircleBorder(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              Text(
                id,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        width: 215,
        height: 205,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Spacer(),
                  direction('N', Icons.north_rounded),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  direction('O', Icons.west_rounded),
                  const Expanded(
                    child: Center(
                      child: Icon(
                        Icons.explore_outlined,
                        size: 40,
                        color: FaroColors.gold,
                      ),
                    ),
                  ),
                  direction('E', Icons.east_rounded),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const Spacer(),
                  direction('S', Icons.south_rounded),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (i) => Container(
            width: 45,
            height: 39,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: FaroColors.night,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: i < game.route.length
                    ? FaroColors.gold
                    : FaroColors.border,
              ),
            ),
            child: Center(
              child: Text(
                i < game.route.length ? game.route[i] : '·',
                style: const TextStyle(
                  fontSize: 15,
                  color: FaroColors.paleGold,
                ),
              ),
            ),
          ),
        ),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          QuietButton(
            'Deshacer',
            icon: Icons.undo_rounded,
            onPressed: game.route.isEmpty ? null : game.undoDirection,
          ),
          QuietButton(
            'Borrar ruta',
            icon: Icons.restart_alt_rounded,
            onPressed: game.route.isEmpty ? null : game.clearRoute,
          ),
        ],
      ),
    ],
  );
}

class StarsPainter extends CustomPainter {
  const StarsPainter({this.ending = false});
  final bool ending;
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();
    for (int i = 0; i < 32; i++) {
      paint.color = FaroColors.paleGold.withValues(
        alpha: .12 + random.nextDouble() * .38,
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height * .7,
        ),
        .4 + random.nextDouble(),
        paint,
      );
    }
    if (ending) {
      final point = Offset(size.width * .5, size.height * .38);
      final path = Path()
        ..moveTo(point.dx, point.dy)
        ..lineTo(size.width, size.height * .14)
        ..lineTo(size.width, size.height * .42)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader =
              LinearGradient(
                colors: [
                  FaroColors.gold.withValues(alpha: .05),
                  FaroColors.paleGold.withValues(alpha: .28),
                ],
              ).createShader(
                Rect.fromLTWH(point.dx, 0, size.width / 2, size.height / 2),
              ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) =>
      ending != oldDelegate.ending;
}
