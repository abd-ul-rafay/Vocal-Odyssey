import 'package:flutter/material.dart';
import '../models/child.dart';

class ChildProvider extends ChangeNotifier {
  List<Child> _children = [];
  int _selectedChild = -1;

  List<Child> get children => _children;
  int get selectedChild => _selectedChild;

  void setSelectedChild(int index) {
    _selectedChild = index;
  }

  void clearSelectedChild() {
    _selectedChild = -1;
  }

  Child? getSelectedChild() => _selectedChild == -1 ? null : _children[_selectedChild];

  void setChildren(List<Child> newChildren) {
    _children = newChildren;
    notifyListeners();
  }

  void addChild(Child child) {
    _children.add(child);
    notifyListeners();
  }

  void updateChild(Child updatedChild) {
    final index = _children.indexWhere((c) => c.id == updatedChild.id);
    if (index != -1) {
      _children[index] = updatedChild;
      notifyListeners();
    }
  }

  void removeChild(String id) {
    _children.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
