import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'student.dart';
import 'platform_utils.dart';
import 'student_service.dart';
import 'class_service.dart';

class StudentFeature extends StatelessWidget {
  const StudentFeature({super.key});

    void _showStudentDetails(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: Text('Age: ${student.age}\nGrade: ${student.grade}\nClass: ${student.className}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStudentDialog(BuildContext context, {Student? student, int? index}) {
    final nameController = TextEditingController(text: student?.name ?? '');
    final ageController = TextEditingController(text: student != null ? student.age.toString() : '');
    final gradeController = TextEditingController(text: student?.grade ?? '');
    final classService = Provider.of<ClassService>(context, listen: false);
    String selectedClass = student?.className ?? (classService.classes.isNotEmpty ? classService.classes.first.className : '');
    final isEdit = student != null && index != null;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Student' : 'Add Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: gradeController,
                  decoration: const InputDecoration(labelText: 'Grade'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedClass.isNotEmpty ? selectedClass : null,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: classService.classes
                      .map((c) => DropdownMenuItem(
                            value: c.className,
                            child: Text('${c.className} (${c.section})'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedClass = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final age = int.tryParse(ageController.text.trim()) ?? 0;
                final grade = gradeController.text.trim();
                if (name.isEmpty || grade.isEmpty || age <= 0 || selectedClass.isEmpty) return;
                final studentService = Provider.of<StudentService>(context, listen: false);
                if (isEdit) {
                  studentService.updateStudent(index, Student(name: name, age: age, grade: grade, className: selectedClass));
                } else {
                  studentService.addStudent(Student(name: name, age: age, grade: grade, className: selectedClass));
                }
                Navigator.of(context).pop();
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
     final studentService = context.watch<StudentService>();
    final studentsList = studentService.students;
      if(kIsWeb){
      return Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Student'),
                onPressed: () => _showStudentDialog(context),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.deepPurple.shade100),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) return Colors.deepPurple.shade50;
                  return null;
                }),
                columns: const [
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: List.generate(studentsList.length, (i) {
                  final s = studentsList[i];
                  return DataRow(cells: [
                    DataCell(
                      GestureDetector(
                        onTap: () => _showStudentDetails(context, s),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade200,
                              child: Text(s.name[0], style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Text(s.age.toString())),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: s.grade == 'A' ? Colors.green.shade100 : s.grade == 'B' ? Colors.orange.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s.grade, style: TextStyle(fontWeight: FontWeight.bold, color: s.grade == 'A' ? Colors.green : s.grade == 'B' ? Colors.orange : s.grade == 'C' ? Colors.red : Colors.grey)),
                    )),
                    DataCell(Text(s.className)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.deepPurple),
                          onPressed: () => _showStudentDialog(context, student: s, index: i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => studentService.deleteStudent(i),
                        ),
                      ],
                    )),
                  ]);
                }),
              ),
            ),
          ),
        ],
      );
    } else if (isMobilePlatform()) {
      return RefreshIndicator(
        onRefresh: () async {},
        child: ListView.builder(
          itemCount: studentsList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Student'),
                  onPressed: () => _showStudentDialog(context),
                ),
              );
            }
            final s = studentsList[index - 1];
            return Dismissible(
              key: ValueKey(s.name + s.age.toString() + s.grade),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red.shade300,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                studentService.deleteStudent(index - 1);
                return false;
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade100, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withAlpha((0.08 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(s.name[0], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cake, size: 16, color: Colors.deepPurple.shade200),
                          const SizedBox(width: 4),
                          Text('Age: ${s.age}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 12),
                          Icon(Icons.grade, size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.grade == 'A' ? Colors.green.shade100 : s.grade == 'B' ? Colors.orange.shade100 : s.grade == 'C' ? Colors.red.shade100 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(s.grade, style: TextStyle(fontWeight: FontWeight.bold, color: s.grade == 'A' ? Colors.green : s.grade == 'B' ? Colors.orange : s.grade == 'C' ? Colors.red : Colors.grey)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.class_, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text('Class: ${s.className}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: () => _showStudentDialog(context, student: s, index: index - 1),
                  ),
                  onTap: () => _showStudentDetails(context, s),
                ),
              ),
            );
          },
        ),
      );
    }else {
      return Center(
        child: SizedBox(
          width: 600,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    onPressed: () => _showStudentDialog(context),
                  ),
                ),
              ),
              Expanded(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.deepPurple.shade100),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) return Colors.deepPurple.shade50;
                    return null;
                  }),
                  columns: const [
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(studentsList.length, (i) {
                    final s = studentsList[i];
                    return DataRow(cells: [
                      DataCell(
                        GestureDetector(
                          onTap: () => _showStudentDetails(context, s),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade200,
                                child: Text(s.name[0], style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 8),
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(s.age.toString())),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: s.grade == 'A' ? Colors.green.shade100 : s.grade == 'B' ? Colors.orange.shade100 : s.grade == 'C' ? Colors.red.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(s.grade, style: TextStyle(fontWeight: FontWeight.bold, color: s.grade == 'A' ? Colors.green : s.grade == 'B' ? Colors.orange : s.grade == 'C' ? Colors.red : Colors.grey)),
                      )),
                      DataCell(Text(s.className)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () => _showStudentDialog(context, student: s, index: i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => studentService.deleteStudent(i),
                          ),
                        ],
                      )),
                    ]);
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

