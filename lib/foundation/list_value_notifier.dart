import 'package:flutter/cupertino.dart';

class ListValueNotifier<T> extends ValueNotifier<List<T>> {
  ListValueNotifier(super.value);
  void addItem(T item) {
    value.add(item);
    notifyListeners();
  }

  void removeItem(T item) {
    value.remove(item);
    notifyListeners();
  }

  void clearItems(){
    value.clear();
    notifyListeners();
  }
}
