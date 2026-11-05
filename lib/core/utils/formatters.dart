/// Funções de formatação de textos exibidos na interface (padrão pt-BR).
abstract final class Formatters {
  static String twoDigits(int value) => value.toString().padLeft(2, '0');

  /// Ex.: 36,2 °C
  static String temperature(double value) =>
      '${value.toStringAsFixed(1).replaceAll('.', ',')} °C';

  /// Ex.: 14:05:09
  static String time(DateTime date) =>
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}:${twoDigits(date.second)}';

  /// Ex.: 21/10 às 14:05
  static String dateTime(DateTime date) =>
      '${twoDigits(date.day)}/${twoDigits(date.month)} às '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';

  /// Ex.: 1h 05min, 12min 30s ou 45s
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${twoDigits(minutes)}min';
    if (minutes > 0) return '${minutes}min ${twoDigits(seconds)}s';
    return '${seconds}s';
  }

  /// Ex.: agora há pouco, há 5 min, há 2 h
  static String elapsedSince(DateTime from, DateTime now) {
    final difference = now.difference(from);
    if (difference.inMinutes < 1) return 'agora há pouco';
    if (difference.inHours < 1) return 'há ${difference.inMinutes} min';
    return 'há ${difference.inHours} h';
  }

  /// Ex.: "João Pereira" vira "JP".
  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
