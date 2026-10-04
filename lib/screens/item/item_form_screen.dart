import 'package:flutter/material.dart';
import 'package:qr_packing_app/core/constants/firestore_constants.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/core/utils/validators.dart';
import 'package:qr_packing_app/models/item_model.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/database_exception.dart';
import 'package:qr_packing_app/services/item_service.dart';
import 'package:qr_packing_app/widgets/app_text_field.dart';
import 'package:qr_packing_app/widgets/error_banner.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class ItemFormScreen extends StatefulWidget {
  /// The box the item belongs to.
  final String boxId;

  /// If [item] is given the screen edits that item, otherwise it adds one.
  final ItemModel? item;

  const ItemFormScreen({super.key, required this.boxId, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemService = ItemService();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;

  String _status = PackingStatus.unpacked;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.itemName ?? '');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
    _quantityController =
        TextEditingController(text: (item?.quantity ?? 1).toString());
    _status = item?.status ?? PackingStatus.unpacked;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
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
      final item = ItemModel(
        id: widget.item?.id ?? '',
        boxId: widget.boxId,
        userId: user.uid,
        itemName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        status: _status,
      );

      if (_isEditing) {
        await _itemService.updateItem(item);
      } else {
        await _itemService.createItem(item);
      }

      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Item updated' : 'Item added')),
      );
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Item' : 'Add Item')),
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
                  label: 'Item name',
                  icon: Icons.label_outline,
                  validator: Validators.itemName,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: Validators.quantity,
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
                  label: _isEditing ? 'Save Changes' : 'Add Item',
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