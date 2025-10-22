import 'package:intl/intl.dart';

extension IntX on int {
  String pluralMasculine(String word) => Intl.plural(
    this,
    one: '$this $word',
    few: '$this $wordа',
    many: '$this $wordов',
    other: '$this $word(ов)',
    locale: 'ru',
  );

  String pluralFeminine(String word) => Intl.plural(
    this,
    one: '$this $wordа',
    few: '$this $wordы',
    many: '$this $word',
    other: '$this $word(а)',
    locale: 'ru',
  );

  String pluralNeuter(String word) => Intl.plural(
    this,
    one: '$this $wordо',
    few: '$this $wordа',
    many: '$this $wordов',
    other: '$this $word(ов)',
    locale: 'ru',
  );
}
