import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    final db = _getDatabseOrThrow();
    getNote(id: note.id);
    final updatesCount = await db.update(notesTable, {
      textColumn: text,
      isSyncedwithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final db = _getDatabseOrThrow();
    final notes = await db.query(notesTable);

    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      return DatabaseNotes.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabseOrThrow();
    return await db.delete(notesTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    final db = _getDatabseOrThrow();

    //make sure owner exists in db
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    //create the notes
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedwithCloudColumn: 1,
    });

    //created database note
    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteuser({required String email}) async {
    final db = _getDatabseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create the notes table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocuemntsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

// : => shorthand for creating constructor
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

//covariant: change behavior of input paramter. In this case, you are overriding the requirement of the comparison of two Objects, allowing for comparison btwn ids instead
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedwithCloudColumn] == 1 ? true : false);

  @override
  String toString() =>
      'Notes, ID = $id, user_id = $userId, is_synced_with_cloud = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedwithCloudColumn = 'is_synced_with_cloud';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS"note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';

const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
      "email"	TEXT NOT NULL UNIQUE,
      "id"	INTEGER NOT NULL,
      PRIMARY KEY("id" AUTOINCREMENT)
      );''';
