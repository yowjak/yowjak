import 'package:flutter/cupertino.dart';

class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateNoteException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllNotesException extends CloudStorageException {}

// U
class CouldNotUpdateNoteException extends CloudStorageException {}

// D
class CouldNotDeleteNoteException extends CloudStorageException {}
