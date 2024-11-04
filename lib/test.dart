import 'dart:math';

final int _lower_case_letter = 0x1;
final int _upper_case_letter = 0x2;
final int _number = 0x4;
final int _symbol = 0x8;

void main() {
  List<String> letters = ['a', 'b', 'c', 'd', 'e'];
  int fixedLength = 3; // Length of the resulting string

  // for (int i = 0; i < 1000; i++) {
  //   // Shuffle the list
  //   letters.shuffle(Random());
  //
  //   // Make sure all letters appear at least once
  //   List<String> result = List.from(letters);
  //
  //   // Add random letters to reach the desired length
  //   while (result.length < fixedLength) {
  //     result.add(letters[Random().nextInt(letters.length)]);
  //   }
  //
  //   // Join the list to form a string
  //   String resultString = result.join('');
  //
  //   print('Resulting String: $resultString');
  // }

  for (int i = 0; i < 1000; i++) {
    final testInts = [0, 1, 2, 3, 4];
    final scopeLength = testInts.length;
    while (testInts.length < fixedLength) {
      testInts.add(Random().nextInt(scopeLength));
    }
    print('Resulting ints: $testInts');
    testInts.shuffle(Random());
    print('Resulting ints 2: $testInts');
  }
}
