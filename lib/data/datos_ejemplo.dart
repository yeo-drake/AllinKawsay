import '../models/cancion.dart';

final List<Cancion> cancionesEjemplo = [
  Cancion(
    id: '1',
    titulo: 'El Cóndor Pasa',
    compositor: 'Daniel Alomía Robles',
    ritmo: 'Huayno',
    region: 'Perú',
    numerofonia: '5 5 6 5 | 3 3 5 3 | 2 2 3 2 | 1 1 2 1',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    pdfUrl: '',
    descripcion: 'Clásico andino. Ejemplo de numerofonía básica.',
  ),
  Cancion(
    id: '2',
    titulo: 'Vírgenes del Sol',
    compositor: 'Jorge Bravo de Rueda',
    ritmo: 'Fox Incaico',
    region: 'Perú',
    numerofonia: '3 5 6 | 5 3 2 | 1 2 3 | 2 - -',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    pdfUrl: '',
    descripcion: 'Melodía tradicional andina.',
  ),
  Cancion(
    id: '3',
    titulo: 'Puno Canta',
    compositor: 'Anónimo',
    ritmo: 'Sikuri',
    region: 'Puno',
    numerofonia: '1 2 3 5 | 3 2 1 | 5 5 6 | 5 - -',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    pdfUrl: '',
    descripcion: 'Sikuri tradicional puneño.',
  ),
];
