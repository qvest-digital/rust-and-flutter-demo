import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/app_router.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class CreateTaskDialog extends StatelessWidget {
  static final _formState = GlobalKey<FormState>();
  static const keyTitle = Key('create_task_form_title');
  static const keyDescription = Key('create_task_form_desc');
  static const keySubmit = Key('create_task_form_submit');

  final Future<bool> Function(String title, String? description) createTask;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  CreateTaskDialog({super.key, required this.createTask});

  @override
  Widget build(BuildContext context) => Form(
        key: _formState,
        child: SimpleDialog(
          title: const Text('Add new Task'),
          contentPadding: const EdgeInsets.all(8),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextFormField(
                    key: keyTitle,
                    controller: titleController,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is mandatory.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  TextFormField(
                    key: keyDescription,
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        hintText: 'Description (optional)'),
                  )
                ],
              ),
            ),
            const Gap(16),
            SimpleDialogOption(
              onPressed: () => context.read<AppRouter>().maybePop(),
              child: const Text('Cancel'),
            ),
            SimpleDialogOption(
              key: keySubmit,
              onPressed: () async {
                final router = context.read<AppRouter>();
                final messenger = ScaffoldMessenger.of(context);
                if (_formState.currentState?.validate() ?? false) {
                  final created = await createTask(
                      titleController.text, descriptionController.text);
                  if (!created) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create Task.'),
                      ),
                    );
                  }
                  router.maybePop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
}
