import 'package:flutter/material.dart';

class Clue {
  const Clue(
    this.id,
    this.title,
    this.subtitle,
    this.body, {
    this.diagram = false,
  });
  final String id, title, subtitle, body;
  final bool diagram;
}

const clues = <String, Clue>{
  'door_note': Clue(
    'door_note',
    'El orden de la noche',
    'Una nota en el banco',
    '«Primero, mirad la luna.\nDespués, escuchad la marea.\nPor último, seguid la estrella.»\n\nTres señales. Tres discos. Leedlas de izquierda a derecha.\n\n— Ada, guardiana del faro',
  ),
  'door_lantern': Clue(
    'door_lantern',
    'El farol de Ada',
    'Una inscripción en el latón',
    '«Ninguna luz llega lejos si camina sola.»\n\nLa llama aún tiene calor. Bajo el asa hay tres pequeñas marcas, como las del armario. La guardiana tuvo que dejar la llave allí.',
  ),
  'chart_sky': Clue(
    'chart_sky',
    'La estrella que permanece',
    'El mapa del cielo',
    'La estrella Polar señala el NORTE.\nEl sol nace por el ESTE.\nEl SUR queda a vuestra espalda.\nEl sol se despide por el OESTE.\n\nN · E · S · O\nUna brújula convierte el viaje en cuatro direcciones.',
  ),
  'chart_log': Clue(
    'chart_log',
    'El último viaje',
    'Del cuaderno de navegación',
    '«Partimos hacia la estrella del Norte.\nGiramos hacia el lugar donde nace el sol.\nBajamos al Sur buscando abrigo.\nY regresamos hacia el ocaso.»\n\nRepetid el recorrido en la brújula, en ese orden.',
  ),
  'light_observation': Clue(
    'light_observation',
    'La postal de la isla',
    'Para quien observa',
    'Ada dibujó el faro antes de marcharse.\n\nContad las estrellas doradas y las ventanas encendidas. Contádselo a quien está leyendo la calibración.',
    diagram: true,
  ),
  'light_formula': Clue(
    'light_formula',
    'La última calibración',
    'Para quien conecta',
    'LÁMPARA = número de estrellas.\n\nLENTE = número de ventanas encendidas.\n\nESPEJO = lámpara + lente − 1.\n\nAjustad las tres marcas y encended la luz. El cristal que encontrasteis ya está colocado.',
  ),
};

class Hotspot {
  const Hotspot(this.label, this.x, this.y, this.icon, {this.clue});
  final String label;
  final double x, y;
  final IconData icon;
  final String? clue;
}

class Room {
  const Room({
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.art,
    required this.hotspots,
    required this.puzzleTitle,
    required this.puzzleSubtitle,
    required this.action,
    required this.successTitle,
    required this.successBody,
    required this.reward,
    required this.hints,
  });
  final String title, eyebrow, description, art, puzzleTitle, puzzleSubtitle;
  final String action, successTitle, successBody, reward;
  final List<Hotspot> hotspots;
  final List<String> hints;
}

const rooms = [
  Room(
    title: 'El umbral',
    eyebrow: 'I · LA LLAVE DEL FARO',
    description:
        'La puerta se cierra suavemente. El farol aún conserva el calor de una despedida.',
    art: 'assets/art/threshold.webp',
    hotspots: [
      Hotspot(
        'Leer la nota del banco',
        .23,
        .65,
        Icons.auto_stories_outlined,
        clue: 'door_note',
      ),
      Hotspot('Examinar el armario', .56, .52, Icons.lock_outline_rounded),
      Hotspot(
        'Examinar el farol',
        .84,
        .43,
        Icons.light_outlined,
        clue: 'door_lantern',
      ),
    ],
    puzzleTitle: 'El armario de Ada',
    puzzleSubtitle: 'Tres discos guardan la llave de la escalera.',
    action: 'Abrir el armario',
    successTitle: 'La llave os esperaba.',
    successBody:
        'La cerradura cede. Dentro, una llave de latón y el olor salado de un mapa antiguo. La sala de cartas ya está a vuestro alcance.',
    reward: 'Llave de latón',
    hints: [
      'La nota del banco habla de tres señales. Tocad su luz para leerla.',
      'El orden se lee de izquierda a derecha: primero el cielo nocturno, después el mar, por último una guía brillante.',
      'La combinación es: LUNA · MAREA · ESTRELLA.',
    ],
  ),
  Room(
    title: 'La sala de cartas',
    eyebrow: 'II · UNA RUTA ENTRE ESTRELLAS',
    description:
        'Sobre la mesa, un viaje que nunca terminó. Quizá la brújula recuerde el camino.',
    art: 'assets/art/charts.webp',
    hotspots: [
      Hotspot(
        'Leer el mapa del cielo',
        .24,
        .40,
        Icons.star_outline_rounded,
        clue: 'chart_sky',
      ),
      Hotspot('Examinar la brújula', .53, .64, Icons.explore_outlined),
      Hotspot(
        'Leer el diario de navegación',
        .82,
        .48,
        Icons.menu_book_outlined,
        clue: 'chart_log',
      ),
    ],
    puzzleTitle: 'La ruta del último barco',
    puzzleSubtitle: 'Marcad las cuatro direcciones del viaje en orden.',
    action: 'Trazar la ruta',
    successTitle: 'La brújula abre su secreto.',
    successBody:
        'Bajo el mapa aparece una lente de cristal. A través de ella, la luz parece recordar cómo brillar. Subid hasta la linterna.',
    reward: 'Lente de cristal',
    hints: [
      'Leed el cuaderno de navegación y comparadlo con el mapa del cielo.',
      'La estrella Polar indica el Norte; el amanecer, el Este; el abrigo está al Sur y el ocaso al Oeste.',
      'Marcad: NORTE → ESTE → SUR → OESTE.',
    ],
  ),
  Room(
    title: 'La linterna',
    eyebrow: 'III · EL ÚLTIMO DESTELLO',
    description:
        'La isla entera parece contener el aliento. Solo falta que dos miradas se conviertan en una luz.',
    art: 'assets/art/lantern_room.webp',
    hotspots: [
      Hotspot(
        'Observar la postal de la isla',
        .22,
        .64,
        Icons.visibility_outlined,
        clue: 'light_observation',
      ),
      Hotspot('Examinar la lente central', .52, .49, Icons.flare_rounded),
      Hotspot(
        'Leer la calibración',
        .82,
        .56,
        Icons.tune_rounded,
        clue: 'light_formula',
      ),
    ],
    puzzleTitle: 'Devolved la luz al mar',
    puzzleSubtitle: 'Una persona observa. La otra conecta las pistas.',
    action: 'Encender el faro',
    successTitle: 'La isla vuelve a respirar.',
    successBody: 'Lo habéis conseguido juntos.',
    reward: 'La luz del faro',
    hints: [
      'La postal y la calibración son dos mitades de la misma pista. Leed una cada uno.',
      'La postal muestra tres estrellas y dos ventanas encendidas. El espejo suma las dos cantidades y resta uno.',
      'Ajustad: LÁMPARA III · LENTE II · ESPEJO IV.',
    ],
  ),
];
