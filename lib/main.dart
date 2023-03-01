import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_project_example/models/node_model.dart';
import 'package:sqflite_project_example/resources/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyNotesScreen());
  }
}

class MyNotesScreen extends StatefulWidget {
  const MyNotesScreen({super.key});

  @override
  State<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends State<MyNotesScreen> {
  final DatabaseLocal db = DatabaseLocal.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<NoteModel> _notelist = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    List<NoteModel> notes = await db.getNotes();
    setState(() {
      _notelist = notes;
    });
  }

  void _saveNote() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    if (title.isNotEmpty && content.isNotEmpty) {
      NoteModel note = NoteModel(title: title, content: content);
      int result = await db.insert(note);
      if (result > 0) {
        _titleController.clear();
        _contentController.clear();
        _loadNotes();
      }
    }
  }

  void _deleteNote(int id) async {
    int result = await db.delete(id);
    if (result > 0) {
      _loadNotes();
    }
  }

  void _addShowAddNoteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Добавить новую запись'),
            content: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'Название'),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: 'Описание'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отменить')),
              TextButton(
                  onPressed: () {
                    _saveNote();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Сохранить')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My notes'),
      ),
      body: Center(
        child: _notelist.isEmpty
            ? const Text('Нет записей')
            : ListView.builder(
                itemCount: _notelist.length,
                itemBuilder: (context, index) {
                  NoteModel note = _notelist[index];
                  return Card(
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteNote(note.id!);
                        },
                      ),
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addShowAddNoteDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
