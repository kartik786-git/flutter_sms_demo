import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'class_item.dart';
import 'class_service.dart';
import 'platform_utils.dart';


class ClassFeature extends StatelessWidget {
   const ClassFeature({super.key});

    void _showClassDialog(BuildContext context, {ClassItem? classItem, int? index}) {
    final classNameController = TextEditingController(text: classItem?.className ?? '');
    final sectionController = TextEditingController(text: classItem?.section ?? '');
    final capacityController = TextEditingController(text: classItem != null ? classItem.capacity.toString() : '');
    final isEdit = classItem != null && index != null;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Class' : 'Add Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: classNameController,
                  decoration: const InputDecoration(labelText: 'Class Name'),
                ),
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
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
                final className = classNameController.text.trim();
                final section = sectionController.text.trim();
                final capacity = int.tryParse(capacityController.text.trim()) ?? 0;
                if (className.isEmpty || section.isEmpty || capacity <= 0) return;
                final classService = Provider.of<ClassService>(context, listen: false);
                if (isEdit) {
                  classService.updateClass(index, ClassItem(className: className, section: section, capacity: capacity));
                } else {
                  classService.addClass(ClassItem(className: className, section: section, capacity: capacity));
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
        final classService = context.watch<ClassService>();
    final classList = classService.classes;
    if (kIsWeb || isDesktopPlatform()) {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Class'),
                onPressed: () => _showClassDialog(context),
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
                  DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Section', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Capacity', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: List.generate(classList.length, (i) {
                  final c = classList[i];
                  return DataRow(cells: [
                    DataCell(Text(c.className)),
                    DataCell(Text(c.section)),
                    DataCell(Text(c.capacity.toString())),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.deepPurple),
                          onPressed: () => _showClassDialog(context, classItem: c, index: i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => classService.deleteClass(i),
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
    }else if (isMobilePlatform()) {
      return ListView.builder(
        itemCount: classList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Class'),
                onPressed: () => _showClassDialog(context),
              ),
            );
          }
          final c = classList[index - 1];
          return Dismissible(
            key: ValueKey(c.className + c.section + c.capacity.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red.shade300,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              classService.deleteClass(index - 1);
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
                  child: Text(c.className[0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(c.className, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Section: ${c.section}'),
                    Text('Capacity: ${c.capacity}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () => _showClassDialog(context, classItem: c, index: index - 1),
                ),
              ),
            ),
          );
        },
      );
    }else {
      // Fallback for other platforms
      return Center(child: Text('No class data available.'));
    }

  }
}
