import 'package:flutter/cupertino.dart';
import 'package:mynotes/views/notes_view.dart';

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => NotesViewState();
}
