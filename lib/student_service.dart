import 'package:flutter/foundation.dart';
import 'student.dart';

class StudentService extends ChangeNotifier {
  final List<Student> _students = [
    Student(name: 'Alice', age: 20, grade: 'A', className: 'Class 1'),
    Student(name: 'Bob', age: 21, grade: 'B', className: 'Class 2'),
    Student(name: 'Charlie', age: 19, grade: 'A', className: 'Class 1'),
    Student(name: 'Diana', age: 22, grade: 'C', className: 'Class 3'),
  ];

  List<Student> get students => List.unmodifiable(_students);

    void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

 void updateStudent(int index, Student student) {
    _students[index] = student;
    notifyListeners();
  }

 void deleteStudent(int index) {
    _students.removeAt(index);
    notifyListeners();
  }
}