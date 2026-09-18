# 🎧 Как слышно?

Цифровая версия настольной игры для компании по мотивам шоу "Громкий вопрос" от ИМПРОКОМ.

## 📖 Описание

"Как слышно?" — командная игра на синхронизацию и взаимопонимание. Игроки надевают наушники с громкой музыкой и пытаются дать одинаковые ответы на вопросы. Побеждают или проигрывают все вместе!

## 🎮 Как играть

### Основная игра (7 раундов)
1. Команда выбирает категорию вопроса: **Лёгкий** / **Средний** / **Сложный**
2. Один из участников читает вопрос с экрана
3. Игроки в наушниках пытаются понять и дать одинаковый ответ
4. Если ответ совпал и правильный — команда получает время:
    - Лёгкий вопрос: **+30 секунд**
    - Средний вопрос: **+1 минута**
    - Сложный вопрос: **+1 минута 30 секунд**

### Финальный раунд
- Накопленное время становится общим банком
- Играются 3 вопроса из оставшихся
- Время расходуется в реальном времени

## ✨ Возможности

- 🎯 **3 уровня сложности** вопросов
- 📦 **10 встроенных паков** с вопросами
- 🛠️ **Конструктор паков** — создавайте свои наборы вопросов прямо в приложении
- 📥 **Импорт паков** — загружайте `.hmq` файлы от других игроков
- 📱 **Адаптивный дизайн** — работает на телефонах и планшетах
- 🔄 **Альбомная ориентация** — оптимизировано для игры в компании

## 🚀 Установка

### Требования
- Flutter 3.0+
- Dart 3.0+
- Android SDK (для Android) / Xcode (для iOS)

### Сборка
```bash
git clone https://github.com/ygbnocap/HEAR-ME-.git
cd hear_me
flutter pub get
flutter run
```

### Сборка APK
```bash
flutter build apk --release
```

## 📁 Структура проекта
```bash
lib/
├── main.dart
├── models/
│   └── question_pack.dart
├── services/
│   └── pack_manager.dart
├── screens/
│   ├── splash_screen.dart
│   ├── disclaimer_screen.dart
│   ├── start_screen.dart
│   ├── time_select_screen.dart
│   ├── pack_select_screen.dart
│   ├── pack_creator_screen.dart
│   ├── question_edit_screen.dart
│   ├── game_screen.dart
│   ├── final_vote_screen.dart
│   └── final_game_screen.dart
├── theme/
│   └── app_colors.dart
└── utils/
    └── responsive.dart
```

## 📝 Формат пака (.hmq)
```bash
{
  "id": "unique_pack_id",
  "name": "Название пака",
  "author": "Автор",
  "description": "Описание",
  "version": "1.0",
  "easy": [
    {"id": "e1", "text": "Вопрос", "answer": "Ответ"}
  ],
  "medium": [
    {"id": "m1", "text": "Вопрос", "answer": "Ответ"}
  ],
  "hard": [
    {"id": "h1", "text": "Вопрос", "answer": "Ответ"}
  ]
}
```

Минимум по 4 вопроса каждого уровня сложности.



## 🎨 Технологии

- Flutter — кроссплатформенная разработка

- Dart — язык программирования

- file_picker — выбор файлов

- path_provider — работа с файловой системой

## 📜 Дисклеймер

Концепт игры вдохновлён и позаимствован с импровизационного шоу "Громкий вопрос" от ИМПРОКОМ. Все права на оригинальный формат, название и концепцию принадлежат их законным владельцам.

Данное приложение является фанатским некоммерческим проектом, созданным исключительно в развлекательных целях. Автор не претендует на интеллектуальную собственность оригинального шоу.

Если вам понравился формат — поддержите оригинальное шоу "Громкий вопрос"!
## 👤 Автор - ygb'baby
------------------
# 🎧 Hear Me?

A digital version of a party board game inspired by the "Loud Question" show by IMPROCOM.
## 📖 Description

"Hear Me?" is a team game about synchronization and mutual understanding. Players put on headphones with loud music and try to give the same answers to questions. You win or lose together as a team!
## 🎮 How to Play

### Main Game (7 rounds)

- The team chooses a question category: Easy / Medium / Hard

- One of the participants reads the question from the screen

- Players in headphones try to understand and give the same answer

- If the answers match and are correct — the team earns time:

    - Easy question: +30 seconds

    - Medium question: +1 minute

    - Hard question: +1 minute 30 seconds

### Final Round
- The accumulated time becomes a shared bank

- 3 questions from the remaining ones are played

- Time is spent in real time

## ✨ Features

- 🎯 **3 difficulty** levels of questions

- 📦 **10 built-in packs** with questions

- 🛠️** Pack Builder** — create your own question sets right in the app

- 📥 **Pack Import** — upload .hmq files from other players

- 📱 **Adaptive Design** — works on phones and tablets

- 🔄 **Landscape Orientation** — optimized for playing in a company

## 🚀 Installation
### Requirements

- Flutter 3.0+

- Dart 3.0+

- Android SDK (for Android) / Xcode (for iOS)

### Build
```bash
git clone https://github.com/ygbnocap/HEAR-ME-.git
cd hear_me
flutter pub get
flutter run
```
### Build APK
```bash
flutter build apk --release
```

## 📁 Project Structure
```bash
lib/
├── main.dart
├── models/
│   └── question_pack.dart
├── services/
│   └── pack_manager.dart
├── screens/
│   ├── splash_screen.dart
│   ├── disclaimer_screen.dart
│   ├── start_screen.dart
│   ├── time_select_screen.dart
│   ├── pack_select_screen.dart
│   ├── pack_creator_screen.dart
│   ├── question_edit_screen.dart
│   ├── game_screen.dart
│   ├── final_vote_screen.dart
│   └── final_game_screen.dart
├── theme/
│   └── app_colors.dart
└── utils/
    └── responsive.dart
```

## 📝 Pack Format (.hmq)
```bash
{
  "id": "unique_pack_id",
  "name": "Pack Name",
  "author": "Author",
  "description": "Description",
  "version": "1.0",
  "easy": [
    {"id": "e1", "text": "Question", "answer": "Answer"}
  ],
  "medium": [
    {"id": "m1", "text": "Question", "answer": "Answer"}
  ],
  "hard": [
    {"id": "h1", "text": "Question", "answer": "Answer"}
  ]
}
```

Minimum of 4 questions per difficulty level.


## 🎨 Technologies

Flutter — cross-platform development

Dart — programming language

file_picker — file selection

path_provider — file system operations
## 📜 Disclaimer

The game concept is inspired by and borrowed from the improvisational show "Loud Question" by IMPROCOM. All rights to the original format, name, and concept belong to their rightful owners.

This application is a fan-made non-commercial project created purely for entertainment purposes. The author does not claim intellectual property rights to the original show and has no direct affiliation with it.

If you enjoyed the format — support the original "Loud Question" show!
## 👤 Author - ygb'baby
