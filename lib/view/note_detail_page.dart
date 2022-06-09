import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_list/helper/noteDatabase.dart';
import 'package:sqlite_list/model/note.dart';
import 'package:sqlite_list/view/edit_note_page.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  //@On Refresh Notes
  Future refreshNote() async {
    setState(() => isLoading = true);
    this.note = await NotesDatabase.instance.readSingleNote(widget.noteId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
      ? const Center(
        child: CircularProgressIndicator()
      )
      : Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Text(
              note.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().format(note.createdTime),
              style: const TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 8),
            Text(
              note.description,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            )
        ],
      ),
    ),
  );

  //@Edit Button
  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note),
        ));

        refreshNote();
      });

  //@Delete Button
  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      //@Delete
      await NotesDatabase.instance.delete(widget.noteId);
      //@Pop Pages
      Navigator.of(context).pop();
    },
  );
}