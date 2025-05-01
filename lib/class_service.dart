import 'package:flutter/foundation.dart';
import 'class_item.dart';

class ClassService extends ChangeNotifier {
    final List<ClassItem> _classes = [
    ClassItem(className: 'Class 1', section: 'A', capacity: 30),
    ClassItem(className: 'Class 2', section: 'B', capacity: 28),
    ClassItem(className: 'Class 3', section: 'A', capacity: 32),
    ClassItem(className: 'Class 4', section: 'C', capacity: 25),
  ];

   List<ClassItem> get classes => List.unmodifiable(_classes);

  void addClass(ClassItem classItem) {
    _classes.add(classItem);
    notifyListeners();
  }

    void updateClass(int index, ClassItem classItem) {
    _classes[index] = classItem;
    notifyListeners();
  }

    void deleteClass(int index) {
    _classes.removeAt(index);
    notifyListeners();
  }
  
}