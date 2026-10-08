/// Turns a time into short text like "5 min ago".
String timeAgo(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final difference = current.difference(time);

  if (difference.inSeconds < 60) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) return '${difference.inHours} h ago';
  if (difference.inDays < 7) return '${difference.inDays} d ago';

  String two(int n) => n.toString().padLeft(2, '0');
  final local = time.toLocal();
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}