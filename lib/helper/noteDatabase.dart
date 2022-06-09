import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite_list/model/note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._int();
  NotesDatabase._int();

  //@State
  static Database? _database;

  //======Method======
  //@Get Database
  Future<Database> get database async {
    if(_database != null) {
      return _database!;
    }
    _database = await _initDB('notes.db');
    return _database!;
  }

  //@Init Database
  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final dbLoc = join(dbPath, path);
    
    return await openDatabase(
      dbLoc,
      version: 1,
      onCreate: _createDB
    ); //@On upgrade to upgrade, also version number up
  }

  //@Create Db
  _createDB(Database db, int version) async {
    //@Type Data
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType = 'BOOLEAN NOT NULL';
    final intType = 'INTEGER NOT NULL';
    final textType = 'TEXT NOT NULL';

    //@Table 1
    await db.execute('''
      CREATE TABLE $tableNotes (
        ${NoteFields.id} $idType,
        ${NoteFields.isImportant} $boolType,
        ${NoteFields.number} $intType,
        ${NoteFields.title} $textType,
        ${NoteFields.description} $textType,
        ${NoteFields.time} $textType
      )
    ''');

    //@Multiple Table 2....
  }

  //@Create Method
  Future<Note> create(Note note) async {
    final db = await instance.database;

    final id = await db.insert(
      tableNotes,
      note.toJson()
    );

    return note.copyWith(id: id);
  }

  //@Raw Create
  Future<int> rawCreate(Note note) async {
    final db = await instance.database;

    final json = note.toJson();
    final columns = '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}, ${NoteFields.number}, ${NoteFields.isImportant}, ${NoteFields.id}';
    final values = '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}, ${json[NoteFields.number]}, ${json[NoteFields.isImportant]}, ${json[NoteFields.id]}';
    final status = await db.rawInsert('INSERT INTO $tableNotes ($columns) VALUES ($values)');

    return status; //return status
  }

  //@Reate Single
  Future<Note> readSingleNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?', //@Question mark for secure (prevent sql injection where
      whereArgs: [id], //add more question mark on where for more args
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first); //@First item becuase only one note obj
    } else {
      throw Exception('ID $id not found');
    }
  }

  //@Read All Notes
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    final orderBy = '${NoteFields.time} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  //@Update
  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  //@Delete
  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  //@Close Database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}