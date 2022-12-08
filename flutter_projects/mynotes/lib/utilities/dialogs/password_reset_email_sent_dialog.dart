import 'package:flutter/cupertino.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password reset',
    content: 'We have sent a reset email. Please check your inbox',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
