import 'dart:math';

class AudioProcessor {
  /// Thuật toán Levenshtein Distance để đo khoảng cách chỉnh sửa giữa 2 chuỗi
  static int calculateLevenshtein(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();
    
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List<int>.generate(b.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  /// Rule-based Mapping kết hợp logic FastText
  /// Lọc và hiệu chỉnh từ khóa địa điểm từ chuỗi âm thanh nhiễu
  static String extractLocationKeyword(String rawCommand) {
    // Tập từ vựng mapping cơ bản (Có thể mở rộng bằng cách nạp từ SQLite)
    List<String> dictionary = ['siêu thị', 'bệnh viện', 'trạm xe buýt', 'nhà thuốc'];
    
    String bestMatch = rawCommand;
    int lowestDistance = 999;

    for (String word in dictionary) {
      int distance = calculateLevenshtein(rawCommand, word);
      // Ngưỡng chấp nhận sai số ký tự
      if (distance < lowestDistance && distance <= 3) { 
        lowestDistance = distance;
        bestMatch = word;
      }
    }

    return bestMatch;
  }
}