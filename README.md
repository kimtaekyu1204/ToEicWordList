# Vocab Master - 토익 단어 학습 앱

토익 기출 단어를 효과적으로 학습할 수 있는 Flutter 앱입니다.

## 주요 기능

- 📚 **학습 모드**: 상세 학습 / 빠른 보기
- 📝 **테스트 모드**: 100문제 4지선다 (단어→뜻 / 뜻→단어)
- 🏆 **만점 릴레이**: 모든 단어 맞출 때까지 무한 반복
- 📋 **오답노트**: 오늘의 오답 + 나만의 단어장
- 📊 **정답률 차트**: 원형 차트로 시각화
- 🌙 **다크모드**: 라이트/다크 테마 지원

## 단어장 정보

- **총 단어 수**: 1,926개
- **카테고리**: 비즈니스, 인사/채용, 마케팅, 재무/회계, 생산/제조, 여행/교통, 쇼핑, 의료, 부동산, 일상생활

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── models/                # 데이터 모델
│   ├── word.dart          # 단어 모델
│   └── test_result.dart   # 테스트 결과 모델
├── providers/             # 상태 관리
│   └── app_provider.dart  # 앱 전역 상태
├── screens/               # 화면
│   ├── home_screen.dart   # 홈 화면
│   ├── study_screen.dart  # 학습 화면
│   ├── test_screen.dart   # 테스트 화면
│   ├── relay_screen.dart  # 만점 릴레이 화면
│   └── wrong_answers_screen.dart  # 오답노트 화면
├── services/              # 서비스
│   └── storage_service.dart  # 로컬 저장소 서비스
├── theme/                 # 테마
│   └── app_theme.dart     # 앱 테마 설정
└── widgets/               # 재사용 위젯
    ├── glass_card.dart    # 글래스 카드 위젯
    ├── gradient_background.dart  # 그라디언트 배경
    ├── pie_chart.dart     # 원형 차트
    └── word_card.dart     # 단어 카드

assets/
└── data/
    └── vocabulary.json    # 단어장 데이터 (1,926개)
```

## 시작하기

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. 웹에서 실행 (개발)

```bash
flutter run -d chrome
```

### 3. APK 빌드 (릴리즈)

APK를 빌드하려면 먼저 서명 키를 설정해야 합니다.

#### 서명 키 생성

```bash
cd android
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

#### key.properties 파일 생성

`android/key.properties` 파일을 생성하고 다음 내용을 입력:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=release
storeFile=../release-key.jks
```

#### APK 빌드

```bash
flutter build apk --release
```

빌드된 APK는 `build/app/outputs/flutter-apk/app-release.apk`에 생성됩니다.

## 단어장 커스터마이징

`assets/data/vocabulary.json` 파일을 수정하여 단어를 추가/수정할 수 있습니다.

### JSON 형식

```json
{
  "title": "단어장 제목",
  "total_words": 1926,
  "vocabulary": [
    {
      "id": 1,
      "word": "accommodate",
      "meaning": "수용하다, 편의를 제공하다",
      "example": "The conference room can accommodate up to 50 participants.",
      "translation": "회의실은 최대 50명의 참가자를 수용할 수 있습니다."
    }
  ]
}
```

## 기술 스택

- **Flutter** 3.35.4
- **Dart** 3.9.2
- **상태관리**: Provider
- **로컬저장소**: Hive + SharedPreferences

## 라이선스

MIT License
