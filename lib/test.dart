final int _lower_case_letter = 0x1;
final int _upper_case_letter = 0x2;
final int _number = 0x4;
final int _symbol = 0x8;

main() {
  int result = 0;
  result |= _lower_case_letter;
  print(
      'testfile $result ${result & _lower_case_letter} ${result & _upper_case_letter} ${result & _number} ${result & _symbol}');
  result |= _upper_case_letter;
  print(
      'testfile $result ${result & _lower_case_letter} ${result & _upper_case_letter} ${result & _number} ${result & _symbol}');
  result |= _number;
  print(
      'testfile $result ${result & _lower_case_letter} ${result & _upper_case_letter} ${result & _number} ${result & _symbol}');
  result |= _symbol;
  print(
      'testfile $result ${result & _lower_case_letter} ${result & _upper_case_letter} ${result & _number} ${result & _symbol}');
  result &= ~_upper_case_letter;
  print(
      'testfile $result ${result & _lower_case_letter} ${result & _upper_case_letter} ${result & _number} ${result & _symbol}');
}
