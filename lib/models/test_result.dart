/// ============================================================
/// TestResult Model - 테스트 결과 모델
/// ============================================================
/// 일일 테스트 결과를 저장하는 모델
/// - date: 테스트 날짜
/// - totalQuestions: 총 문제 수
/// - correctAnswers: 정답 수
/// - wrongWords: 틀린 단어 목록
/// - testType: 테스트 유형 (단어→뜻 / 뜻→단어)
/// ============================================================

class TestResult {
  /// 테스트 날짜 (YYYY-MM-DD 형식)
  final String date;
  
  /// 총 문제 수
  final int totalQuestions;
  
  /// 정답 수
  final int correctAnswers;
  
  /// 틀린 단어 목록 (단어 문자열 리스트)
  final List<String> wrongWords;
  
  /// 테스트 유형: 'wordToMeaning' 또는 'meaningToWord'
  final String testType;
  
  /// 테스트 완료 시간
  final String completedAt;

  const TestResult({
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongWords,
    required this.testType,
    required this.completedAt,
  });

  /// 정답률 계산 (퍼센트)
  double get accuracy => 
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  /// 틀린 문제 수
  int get wrongCount => totalQuestions - correctAnswers;

  /// JSON에서 TestResult 객체 생성
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      date: json['date'] as String? ?? '',
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongWords: (json['wrongWords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      testType: json['testType'] as String? ?? 'wordToMeaning',
      completedAt: json['completedAt'] as String? ?? '',
    );
  }

  /// TestResult 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongWords': wrongWords,
      'testType': testType,
      'completedAt': completedAt,
    };
  }

  @override
  String toString() => 
      'TestResult(date: $date, score: $correctAnswers/$totalQuestions)';
}
