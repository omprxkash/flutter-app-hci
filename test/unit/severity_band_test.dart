import 'package:flutter_test/flutter_test.dart';
import 'package:medquiz_hci/features/quiz/domain/entities/severity_band.dart';

void main() {
  test('SeverityBand.contains is inclusive on both ends', () {
    const SeverityBand b = StandardSeverityBands.moderate; // 10-14
    expect(b.contains(10), isTrue);
    expect(b.contains(12), isTrue);
    expect(b.contains(14), isTrue);
    expect(b.contains(9), isFalse);
    expect(b.contains(15), isFalse);
  });

  test('PHQ-9 standard bands cover 0-27 with no gaps', () {
    const List<SeverityBand> bands = <SeverityBand>[
      StandardSeverityBands.minimal,
      StandardSeverityBands.mild,
      StandardSeverityBands.moderate,
      StandardSeverityBands.moderatelySevere,
      StandardSeverityBands.severe,
    ];

    for (int score = 0; score <= 27; score++) {
      final Iterable<SeverityBand> matching = bands.where(
        (b) => b.contains(score),
      );
      expect(
        matching.length,
        1,
        reason: 'Score $score must match exactly one band',
      );
    }
  });
}
