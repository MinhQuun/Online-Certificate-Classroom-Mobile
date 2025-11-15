import 'package:flutter/foundation.dart';

enum HomeTab { courses, cart, learning, account }

class HomeNavigationController extends ChangeNotifier {
  HomeTab _current = HomeTab.courses;

  HomeTab get current => _current;

  int get currentIndex => HomeTab.values.indexOf(_current);

  void select(HomeTab tab) {
    if (_current == tab) return;
    _current = tab;
    notifyListeners();
  }

  void selectByIndex(int index) {
    if (index < 0 || index >= HomeTab.values.length) return;
    select(HomeTab.values[index]);
  }
}
