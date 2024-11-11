import 'package:flutter/material.dart';
import 'note_database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primaryColor: Colors.yellow,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: NotesApp(),
    );
  }
}

class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  String searchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // Load notes from the SQLite database
  void loadNotes() async {
    final allNotes = await NoteDatabase.instance.readAllNotes();
    setState(() {
      notes = allNotes;
      filteredNotes = allNotes;
    });
  }

  // Add a new note
  void addNote(String title, String content) async {
    final newNote = Note(
      title: title,
      content: content,
    );
    await NoteDatabase.instance.create(newNote);
    loadNotes();
  }

  // Update an existing note
  void updateNote(Note note, String newTitle, String newContent) async {
    final updatedNote = Note(
      id: note.id,
      title: newTitle,
      content: newContent,
    );
    await NoteDatabase.instance.update(updatedNote);
    loadNotes();
  }

  // Delete a note
  void deleteNote(int id) async {
    await NoteDatabase.instance.delete(id);
    loadNotes();
  }

  // Filter notes based on the search query
  void filterNotes(String query) {
    final filtered = notes.where((note) {
      final noteTitle = note.title.toLowerCase();
      final noteContent = note.content.toLowerCase();
      final searchLower = query.toLowerCase();

      return noteTitle.contains(searchLower) || noteContent.contains(searchLower);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredNotes = filtered;
    });
  }

  // Show a dialog to add or edit notes
  void showNoteDialog({Note? note}) {
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: SingleChildScrollView( // Wrap the content in a scrollable view
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: null,  // Allows unlimited lines of text
                  keyboardType: TextInputType.multiline,  // Ensures multiline input
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (note == null) {
                  addNote(
                    titleController.text,
                    contentController.text,
                  );
                } else {
                  updateNote(
                    note,
                    titleController.text,
                    contentController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Yellow button color
              ),
              child: Text(note == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          onChanged: (query) => filterNotes(query),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.black45),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.black), // Search text color
        )
            : Text('Notes App'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                  filteredNotes = notes; // Reset the notes list
                }
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () {
              showNoteDialog(note: note);
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteNote(note.id!);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNoteDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
