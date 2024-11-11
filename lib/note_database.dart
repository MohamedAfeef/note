import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  final int? id;
  final String title;
  final String content;

  Note({
    this.id,
    required this.title,
    required this.content,
  });

  // Convert Note object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  // Convert Map to Note object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
    );
  }
}

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Define database schema
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  // Insert a new note
  Future<int> create(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Read all notes
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Update an existing note
  Future<int> update(Note note) async {
    final db = await instance.database;

    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note
  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
