import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/core/utils/validators.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/screens/box/box_details_screen.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/database_exception.dart';
import 'package:qr_packing_app/widgets/app_text_field.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class CreateBoxScreen extends StatefulWidget {
  /// If [box] is given the screen edits that box, otherwise it creates one.
  final BoxModel? box;

  const CreateBoxScreen({super.key, this.box});

  @override
  State<CreateBoxScreen> createState() => _CreateBoxScreenState();
}

class _CreateBoxScreenState extends State<CreateBoxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boxService = BoxService();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  String? _category;
  String _status = PackingStatus.unpacked;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.box != null;

  @override
  void initState() {
    super.initState();
    final box = widget.box;
    _nameController = TextEditingController(text: box?.boxName ?? '');
    _locationController = TextEditingController(text: box?.location ?? '');
    _descriptionController =
        TextEditingController(text: box?.description ?? '');
    final category = box?.category;
    _category = (category == null || category.isEmpty) ? null : category;
    _status = box?.status ?? PackingStatus.unpacked;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthService().currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Please log in again.');
      return;
    }

    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final box = BoxModel(
        id: widget.box?.id ?? '',
        userId: user.uid,
        boxName: _nameController.text.trim(),
        category: _category!,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
      );

      if (_isEditing) {
        await _boxService.updateBox(box);
        if (!mounted) return;
        Navigator.pop(context);
        messenger.showSnackBar(const SnackBar(content: Text('Box updated')));
      } else {
        final newId = await _boxService.createBox(box);
        if (!mounted) return;
        // Replace this form with the new box's details screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BoxDetailsScreen(boxId: newId)),
        );
        messenger.showSnackBar(const SnackBar(content: Text('Box created')));
      }
    } on DatabaseException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If an old box has a category that is not in the list, keep it available.
    final categories = [...AppConstants.boxCategories];
    final selected = _category;
    if (selected != null && !categories.contains(selected)) {
      categories.add(selected);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Box' : 'Create Box')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Box name',
                  icon: Icons.inventory_2_outlined,
                  validator: Validators.boxName,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.categoryLightColor(c),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                AppConstants.categoryIcon(c),
                                size: 16,
                                color: AppColors.categoryColor(c),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(c, style: AppTextStyles.body),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                  validator: (value) =>
                      value == null ? 'Please choose a category' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _locationController,
                  label: 'Location (e.g. Storage Room)',
                  icon: Icons.place_outlined,
                  validator: Validators.location,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                  validator: Validators.description,
                ),
                const SizedBox(height: 20),
                const Text('Packing status', style: AppTextStyles.bodySecondary),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    selectedBackgroundColor: AppColors.primaryLight,
                    selectedForegroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: PackingStatus.unpacked,
                      label: Text('Unpacked'),
                      icon: Icon(Icons.radio_button_unchecked),
                    ),
                    ButtonSegment(
                      value: PackingStatus.packed,
                      label: Text('Packed'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                  ],
                  selected: {_status},
                  onSelectionChanged: (selection) {
                    setState(() => _status = selection.first);
                  },
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                PrimaryButton(
                  label: _isEditing ? 'Save Changes' : 'Create Box',
                  icon: Icons.check,
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}