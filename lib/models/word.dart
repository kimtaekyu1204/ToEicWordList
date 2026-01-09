/// ============================================================
/// Word Model - 단어 데이터 모델
/// ============================================================
/// 토익 단어의 기본 정보를 담는 모델 클래스
/// - word: 영어 단어
/// - meaning: 한국어 뜻
/// - example: 예문
/// - translation: 예문 번역
/// ============================================================

class Word {
  /// 영어 단어
  final String word;
  
  /// 한국어 뜻
  final String meaning;
  
  /// 영어 예문
  final String example;
  
  /// 예문의 한국어 번역
  final String translation;

  const Word({
    required this.word,
    required this.meaning,
    required this.example,
    required this.translation,
  });

  /// JSON에서 Word 객체 생성
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      example: json['example'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
    );
  }

  /// Word 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'example': example,
      'translation': translation,
    };
  }

  /// 복사본 생성 (일부 필드 변경 가능)
  Word copyWith({
    String? word,
    String? meaning,
    String? example,
    String? translation,
  }) {
    return Word(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      translation: translation ?? this.translation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Word && other.word == word;
  }

  @override
  int get hashCode => word.hashCode;

  @override
  String toString() => 'Word(word: $word, meaning: $meaning)';
}
