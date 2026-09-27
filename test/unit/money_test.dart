import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/money/money_format.dart';
import 'package:patrimonio/core/money/money_parser.dart';
import 'package:patrimonio/core/money/percent.dart';

void main() {
  group('Money', () {
    test('somma e sottrazione restano esatte in centesimi', () {
      // 0,1 + 0,2 in double darebbe 0,30000000000000004.
      expect(const Money(10) + const Money(20), const Money(30));
      expect(Money.sum(List.filled(1000, const Money(1))), const Money(1000));
      expect(const Money.euros(5) - const Money.euros(8), const Money(-300));
    });

    test('confronti e segno', () {
      expect(const Money(-1).isNegative, isTrue);
      expect(Money.zero.isZero, isTrue);
      expect(const Money(5) > const Money(3), isTrue);
    });
  });

  group('Percent.change', () {
    test('variazione positiva arrotondata a due decimali', () {
      // (184.520 − 181.280) / 181.280 = 1,787…% → 1,79%
      final p = Percent.change(
        current: const Money.euros(184520),
        previous: const Money.euros(181280),
      );
      expect(p, const Percent(179));
    });

    test('arrotondamento dalla metà lontano da zero', () {
      expect(roundedDivision(BigInt.from(1785), BigInt.from(1000)), 2);
      expect(roundedDivision(BigInt.from(-1785), BigInt.from(1000)), -2);
      expect(roundedDivision(BigInt.from(1784), BigInt.from(1000)), 2);
      expect(roundedDivision(BigInt.from(1449), BigInt.from(1000)), 1);
      expect(roundedDivision(BigInt.from(15), BigInt.from(10)), 2);
      expect(roundedDivision(BigInt.from(-15), BigInt.from(10)), -2);
    });

    test('precedente zero: percentuale non definita', () {
      expect(
        Percent.change(current: const Money.euros(100), previous: Money.zero),
        isNull,
      );
    });

    test('precedente negativo: il segno indica il miglioramento', () {
      // Da −10.000 € a −5.000 €: +50%, non −50%.
      final p = Percent.change(
        current: const Money.euros(-5000),
        previous: const Money.euros(-10000),
      );
      expect(p, const Percent(5000));
    });

    test('peggioramento da negativo a più negativo', () {
      final p = Percent.change(
        current: const Money.euros(-15000),
        previous: const Money.euros(-10000),
      );
      expect(p, const Percent(-5000));
    });

    test('valori enormi senza overflow', () {
      final p = Percent.change(
        current: const Money(Money.maxCents),
        previous: const Money(1),
      );
      expect(p!.basisPoints, greaterThan(0));
    });
  });

  group('largestRemainder', () {
    test('la somma è sempre esattamente il totale', () {
      final result = largestRemainder([1, 1, 1], 100);
      expect(result.reduce((a, b) => a + b), 100);
      expect(result, [34, 33, 33]);
    });

    test('pesi zero restano a zero', () {
      expect(largestRemainder([0, 5, 5], 100), [0, 50, 50]);
      expect(largestRemainder([0, 0], 100), [0, 0]);
    });

    test('casi realistici del donut', () {
      final result = largestRemainder([
        3436000,
        9042000,
        15000000,
        1486000,
      ], 100);
      expect(result.reduce((a, b) => a + b), 100);
    });
  });

  group('MoneyFormat', () {
    test('formato italiano con centesimi solo se presenti', () {
      expect(MoneyFormat.format(const Money.euros(184520)), '€184.520');
      expect(MoneyFormat.format(const Money(18452050)), '€184.520,50');
      expect(MoneyFormat.format(const Money(5)), '€0,05');
      expect(MoneyFormat.format(const Money.euros(-52000)), '−€52.000');
      expect(
        MoneyFormat.format(const Money.euros(3240), signed: true),
        '+€3.240',
      );
      expect(MoneyFormat.format(Money.zero, signed: true), '€0');
    });

    test('euro interi arrotondati', () {
      expect(MoneyFormat.whole(const Money(18452050)), '€184.521');
      expect(MoneyFormat.whole(const Money(18452049)), '€184.520');
      expect(MoneyFormat.whole(const Money(-150)), '−€2');
    });

    test('forma compatta per gli assi', () {
      expect(MoneyFormat.compact(const Money.euros(950)), '€950');
      expect(MoneyFormat.compact(const Money.euros(9500)), '€9,5k');
      expect(MoneyFormat.compact(const Money.euros(184520)), '€185k');
      expect(MoneyFormat.compact(const Money.euros(1234567)), '€1,2M');
      expect(MoneyFormat.compact(const Money.euros(-52000)), '−€52k');
    });

    test('testo per i campi e per lo screen reader', () {
      expect(MoneyFormat.input(const Money.euros(15520)), '15.520');
      expect(MoneyFormat.input(const Money(1552050)), '15.520,50');
      expect(MoneyFormat.spoken(const Money.euros(-52000)), 'meno 52.000 euro');
    });

    test('percentuali', () {
      expect(PercentFormat.format(const Percent(179)), '+1,79%');
      expect(PercentFormat.format(const Percent(-50)), '−0,50%');
      expect(PercentFormat.format(const Percent(324), decimals: 1), '+3,2%');
      expect(PercentFormat.format(const Percent(325), decimals: 1), '+3,3%');
      expect(
        PercentFormat.format(
          Percent.change(current: const Money(1), previous: const Money(1))!,
        ),
        '0,00%',
      );
      expect(PercentFormat.spoken(const Percent(179)), 'più 1,79 per cento');
    });
  });

  group('MoneyParser', () {
    final cases = <String, int>{
      '12.500': 1250000,
      '12500,5': 1250050,
      '12500,50': 1250050,
      '12.50': 1250,
      '1.5': 150,
      '€ 1.250.000': 125000000,
      '1 250 000': 125000000,
      '0,5': 50,
      ',5': 50,
      '': 0,
      '   ': 0,
      '+100': 10000,
      '12.': 1200,
    };
    cases.forEach((input, cents) {
      test('"$input" → $cents centesimi', () {
        expect(MoneyParser.parse(input), Money(cents));
      });
    });

    final errors = <String, MoneyParseError>{
      '12,345': MoneyParseError.tooManyDecimals,
      '-5': MoneyParseError.negative,
      '−5': MoneyParseError.negative,
      'abc': MoneyParseError.invalid,
      '1,2,3': MoneyParseError.invalid,
      '1.2345': MoneyParseError.invalid,
      '12.34.5': MoneyParseError.invalid,
      '1234567890123': MoneyParseError.tooLarge,
    };
    errors.forEach((input, error) {
      test('"$input" → errore $error', () {
        expect(MoneyParser.validate(input), error);
      });
    });
  });
}
