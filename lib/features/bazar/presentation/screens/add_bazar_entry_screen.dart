import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/bazar_providers.dart';

class AddBazarEntryScreen extends ConsumerStatefulWidget {
  const AddBazarEntryScreen({super.key});

  @override
  ConsumerState<AddBazarEntryScreen> createState() => _AddBazarEntryScreenState();
}

class _AddBazarEntryScreenState extends ConsumerState<AddBazarEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  XFile? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(currentUserProvider);
    if (user == null || user.messId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details not available.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      await ref.read(bazarRepositoryProvider).addBazarEntry(
            messId: user.messId!,
            userId: user.uid,
            userName: user.displayName ?? 'Manager',
            amount: amount,
            date: _selectedDate,
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
            localImagePath: _selectedImage?.path,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bazar entry added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding entry: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bazar Entry'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Amount (BDT ৳)',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter bazar amount';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid positive amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Date selection field
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary.withAlpha(100)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${AppDateUtils.formatDisplayDate(_selectedDate)}',
                          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                        ),
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Note / Item list (Optional)',
                  controller: _noteController,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Receipt Photo (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImage!.path),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Save Bazar Entry',
                  isLoading: _isUploading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
