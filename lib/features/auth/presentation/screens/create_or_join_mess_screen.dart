import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';

class CreateOrJoinMessScreen extends ConsumerStatefulWidget {
  const CreateOrJoinMessScreen({super.key});

  @override
  ConsumerState<CreateOrJoinMessScreen> createState() => _CreateOrJoinMessScreenState();
}

class _CreateOrJoinMessScreenState extends ConsumerState<CreateOrJoinMessScreen> {
  bool _isCreating = true; // true = Create Mess, false = Join Mess

  final _messNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _messNameController.dispose();
    _nameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isCreating) {
        ref.read(authNotifierProvider.notifier).createMess(
              _messNameController.text.trim(),
              _nameController.text.trim(),
            );
      } else {
        ref.read(authNotifierProvider.notifier).joinMess(
              _inviteCodeController.text.trim(),
              _nameController.text.trim(),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is Authenticated && next.user.hasJoinedMess) {
        context.go('/dashboard');
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  _isCreating ? 'Create a New Mess' : 'Join an Existing Mess',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCreating
                      ? 'You will become the Mess Manager and can invite members'
                      : 'Enter the invite code provided by your Mess Manager',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Toggle mode selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Create Mess')),
                        selected: _isCreating,
                        onSelected: (selected) {
                          if (selected) setState(() => _isCreating = true);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Join Mess')),
                        selected: !_isCreating,
                        onSelected: (selected) {
                          if (selected) setState(() => _isCreating = false);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Your Full Name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_isCreating) ...[
                  AppTextField(
                    label: 'Mess Name',
                    controller: _messNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter mess name';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  AppTextField(
                    label: 'Invite Code (6 characters)',
                    controller: _inviteCodeController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter invite code';
                      }
                      if (value.trim().length < 6) {
                        return 'Invite code must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),
                PrimaryButton(
                  label: _isCreating ? 'Create Mess & Continue' : 'Join Mess & Continue',
                  isLoading: isLoading,
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
