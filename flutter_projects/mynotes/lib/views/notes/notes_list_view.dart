import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNotes note);

class NotesListview extends StatelessWidget {
  final List<DatabaseNotes> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  const NotesListview({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
            onTap: () {
              onTap(note);
            },
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),
            ));
      },
    );
  }
}
