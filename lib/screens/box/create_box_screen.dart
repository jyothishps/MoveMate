import 'package:flutter/material.dart';
import 'package:qr_packing_app/widgets/app_text_field.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class CreateBoxScreen extends StatelessWidget {
  const CreateBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Box')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTextField(
                label: 'Box name',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 16),
              const AppTextField(
                label: 'Category (e.g. Kitchen)',
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 16),
              const AppTextField(
                label: 'Location (e.g. Storage Room)',
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 16),
              const AppTextField(
                label: 'Description',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Box',
                icon: Icons.check,
                // Placeholder: saving to Firestore comes in Phase 6.
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}