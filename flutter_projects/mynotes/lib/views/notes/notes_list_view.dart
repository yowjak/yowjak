import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef DeleteNodeCallback = void Function(DatabaseNotes note);

class NotesListview extends StatelessWidget {
  final List<DatabaseNotes> notes;
  final DeleteNodeCallback onDeleteNote;
  const NotesListview({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
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
