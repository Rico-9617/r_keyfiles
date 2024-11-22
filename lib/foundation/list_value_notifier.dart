import 'package:flutter/cupertino.dart';

class ListValueNotifier<T> extends ValueNotifier<List<T>> {
  ListValueNotifier(super.value);

  int get size => value.length;

  void addItem(T item) {
    value.add(item);
    notifyListeners();
  }

  void removeAtIndex(int index) {
    value.removeAt(index);
    notifyListeners();
  }

  void removeItem(T item) {
    value.remove(item);
    notifyListeners();
  }

  void removeRangeItems(int start, int end) {
    value.removeRange(start, end);
    notifyListeners();
  }

  void clearItems() {
    value.clear();
    notifyListeners();
  }

  void addAllItems(Iterable<T> items) {
    value.addAll(items);
    notifyListeners();
  }

  void removeAllItems() {
    value.clear();
    notifyListeners();
  }

  void replaceAllItems(Iterable<T> items) {
    value.clear();
    value.addAll(items);
    notifyListeners();
  }
}
