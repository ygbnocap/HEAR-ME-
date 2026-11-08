import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/models/question_pack.dart';

Map<String, dynamic> fixture({String id = 'test_pack', String name = 'Пак'}) =>
    {
      'id': id,
      'name': name,
      for (final level in ['easy', 'medium', 'hard'])
        level: List.generate(
            4, (i) => <String, dynamic>{'id': '$level$i', 'text': 'Вопрос $i'}),
    };

void main() {
  test('optional absent and null answers remain valid', () {
    final json = fixture();
    json['easy'][0]['answer'] = null;
    expect(QuestionPack.fromJson(json).isValid, isTrue);
  });
  test('unsafe IDs rejected on every platform', () {
    for (final id in [
      '',
      '../outside',
      '/absolute',
      r'C:\absolute',
      r'\\server\share',
      r'a\b',
      'a/b',
      '.',
      '..',
      'a:stream',
      'NUL',
      'con.txt',
      'LPT1',
      'trailing.',
      'trailing ',
      'a\u0000b'
    ]) {
      expect(QuestionPack.fromJson(fixture(id: id)).isValid, isFalse,
          reason: id);
    }
    expect(QuestionPack.fromJson(fixture(id: 'safe-ID_123')).isValid, isTrue);
    expect(
        QuestionPack.fromJson(fixture(id: 'Русский пак.v1')).isValid, isTrue);
  });
  test('semantic blanks and insufficient difficulty rejected', () {
    expect(QuestionPack.fromJson(fixture(name: '  ')).isValid, isFalse);
    final text = fixture();
    text['easy'][0]['text'] = '\n ';
    expect(QuestionPack.fromJson(text).isValid, isFalse);
    final answer = fixture();
    answer['hard'][0]['answer'] = ' ';
    expect(QuestionPack.fromJson(answer).isValid, isFalse);
    final short = fixture();
    short['medium'].removeLast();
    expect(QuestionPack.fromJson(short).isValid, isFalse);
  });
  test('more than four questions and duplicate question IDs still supported',
      () {
    final json = fixture();
    json['easy'].add(json['easy'][0]);
    expect(QuestionPack.fromJson(json).isValid, isTrue);
    expect(
        QuestionPack.fromHmqString(jsonEncode(json)).easyQuestions.length, 5);
  });
  test('malformed JSON and wrong types fail parsing', () {
    expect(() => QuestionPack.fromHmqString('{'), throwsFormatException);
    expect(() => QuestionPack.fromJson({'id': 1}), throwsA(isA<TypeError>()));
  });
}
