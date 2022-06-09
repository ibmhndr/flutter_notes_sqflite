import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqlite_list/helper/noteDatabase.dart';
import 'package:sqlite_list/model/note.dart';
import 'package:sqlite_list/view/edit_note_page.dart';
import 'package:sqlite_list/view/note_detail_page.dart';
import 'package:sqlite_list/view_component/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    this.notes = await NotesDatabase.instance.readAllNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Catatan',
        style: TextStyle(fontSize: 24),
      ),
      // actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
      //If Loading
      ? const CircularProgressIndicator()
      //If Notes Is Empty
      : notes.isEmpty
        ? const Text(
        'Tidak Terdapat Catatan',
        style: TextStyle(color: Colors.white, fontSize: 24),
      )
      //Else Build Notes
      : buildNotes(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.white,
      child: const Icon(
        Icons.add,
        color: Colors.black,
      ),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditNotePage()),
        );

        refreshNotes();
      },
    ),
  );

  //Widget to Build Notes
  Widget buildNotes() => MasonryGridView.count(
    padding: const EdgeInsets.all(8),
    itemCount: notes.length,
    // staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    itemBuilder: (context, index) {
      final note = notes[index];

      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NoteDetailPage(noteId: note.id!),
          ));

          refreshNotes();
        },
        child: NoteCardWidget(note: note, index: index),
      );
    },
  );
}