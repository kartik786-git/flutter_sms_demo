import 'package:flutter/material.dart';
import 'dart:io' show Platform; // Used for platform detection (except Web)
import 'package:flutter/foundation.dart'
    show kIsWeb; // Used to detect if running on Web

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter SMS appp '),
    );
  }
}

// Model class representing a student
class Student {
  final String name;
  final int age;
  final String grade;
  Student({required this.name, required this.age, required this.grade});
}

// Initial list of students
final List<Student> students = [
  Student(name: 'Alice', age: 20, grade: 'A'),
  Student(name: 'Bob', age: 21, grade: 'B'),
  Student(name: 'Charlie', age: 19, grade: 'A'),
  Student(name: 'Diana', age: 22, grade: 'C'),
];

// Main home page widget (stateful)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State for MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  List<Student> studentsList = List.from(students); // Local list of students
  Student? editingStudent; // Currently editing student (if any)
  int? editingIndex; // Index of editing student (if any)

  // Shows dialog for adding or editing a student

  void _showStudentDialog({Student? student, int? index}) {
    final nameController = TextEditingController(text: student?.name ?? '');
    final ageController = TextEditingController(
      text: student?.age != null ? student!.age.toString() : '',
    );
    final gradeController = TextEditingController(text: student?.grade ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(student == null ? 'Add Student' : 'Edit Student'),
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
                if (name.isEmpty || grade.isEmpty || age <= 0) return;
                setState(() {
                  if (student == null) {
                    studentsList.add(
                      Student(name: name, age: age, grade: grade),
                    );
                  } else if (index != null) {
                    studentsList[index] = Student(
                      name: name,
                      age: age,
                      grade: grade,
                    );
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(student == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  // Shows confirmation dialog and deletes a student if confirmed
  void _deleteStudent(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Student'),
            content: const Text(
              'Are you sure you want to delete this student?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    studentsList.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  // Shows student details (dialog for Web/Desktop, new screen for Mobile)
  void _showStudentDetails(Student student) {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop/Web: Show as dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      student.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Age: ${student.age}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Grade: ', style: TextStyle(fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              student.grade == 'A'
                                  ? Colors.green.shade100
                                  : student.grade == 'B'
                                  ? Colors.orange.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          student.grade,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                student.grade == 'A'
                                    ? Colors.green
                                    : student.grade == 'B'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } else {
      // Mobile: Navigate to new screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StudentDetailScreen(student: student),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget studentListWidget;

    Future<void> _refreshStudents() async {
      setState(() {
        studentsList = List.from(
          students,
        ); // Reset to initial list or fetch from source
      });
    }
if (kIsWeb) {
      // Web: DataTable with edit/delete icons
      studentListWidget = SingleChildScrollView(
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
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(studentsList.length, (i) {
            final s = studentsList[i];
            return DataRow(cells: [
              DataCell(
                GestureDetector(
                  onTap: () => _showStudentDetails(s),
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
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: () => _showStudentDialog(student: s, index: i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteStudent(i),
                  ),
                ],
              )),
            ]);
          }),
        ),
      );
    } 
    else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Card list with swipe to delete and trailing edit icon
      studentListWidget = RefreshIndicator(
        onRefresh: _refreshStudents,
        child: ListView.builder(
          itemCount: studentsList.length,
          itemBuilder: (context, index) {
            final s = studentsList[index];
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
                _deleteStudent(index);
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
                    child: Text(
                      s.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: 16,
                        color: Colors.deepPurple.shade200,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Age: ${s.age}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.grade, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              s.grade == 'A'
                                  ? Colors.green.shade100
                                  : s.grade == 'B'
                                  ? Colors.orange.shade100
                                  : s.grade == 'C'
                                  ? Colors.red.shade100
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.grade,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                s.grade == 'A'
                                    ? Colors.green
                                    : s.grade == 'B'
                                    ? Colors.orange
                                    : s.grade == 'C'
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed:
                        () => _showStudentDialog(student: s, index: index),
                  ),
                  onTap: () => _showStudentDetails(s),
                ),
              ),
            );
          },
        ),
      );
    } 
    else {
      // Desktop: DataTable with edit/delete icons
      studentListWidget = Center(
        child: SizedBox(
          width: 600,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              Colors.deepPurple.shade100,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered))
                return Colors.deepPurple.shade50;
              return null;
            }),
            columns: const [
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Age',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Grade',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: List.generate(studentsList.length, (i) {
              final s = studentsList[i];
              return DataRow(
                cells: [
                  DataCell(
                    GestureDetector(
                      onTap: () => _showStudentDetails(s),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade200,
                            child: Text(
                              s.name[0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(s.age.toString())),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            s.grade == 'A'
                                ? Colors.green.shade100
                                : s.grade == 'B'
                                ? Colors.orange.shade100
                                : s.grade == 'C'
                                ? Colors.red.shade100
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.grade,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              s.grade == 'A'
                                  ? Colors.green
                                  : s.grade == 'B'
                                  ? Colors.orange
                                  : s.grade == 'C'
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.deepPurple,
                          ),
                          onPressed:
                              () => _showStudentDialog(student: s, index: i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStudent(i),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.white),
            const SizedBox(width: 8),
            Text(widget.title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        elevation: 4,
        actions: [
          if (kIsWeb ||
              Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh',
              onPressed: _refreshStudents,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: studentListWidget,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Student',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontSize: 16,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
      ),
    );
  }
}

// Screen to show student details (used on mobile)
class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Text(student.name, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    student.name[0],
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cake, color: Colors.deepPurple.shade200),
                    const SizedBox(width: 8),
                    Text(
                      'Age: ${student.age}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grade, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            student.grade == 'A'
                                ? Colors.green.shade100
                                : student.grade == 'B'
                                ? Colors.orange.shade100
                                : student.grade == 'C'
                                ? Colors.red.shade100
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        student.grade,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              student.grade == 'A'
                                  ? Colors.green
                                  : student.grade == 'B'
                                  ? Colors.orange
                                  : student.grade == 'C'
                                  ? Colors.red
                                  : Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
