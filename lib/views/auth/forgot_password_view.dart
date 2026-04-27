import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_appbar.dart';
import '../../core/widgets/dna_pattern_background.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/dialog_helper.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();

    final success = await viewModel.resetPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      DialogHelper.showSuccessDialog(
        context,
        title: 'Email Sent',
        message: 'Password reset link has been sent to your email',
        onDismiss: () => Navigator.of(context).pop(),
      );
    } else {
      DialogHelper.showErrorDialog(
        context,
        message: viewModel.errorMessage ?? AppStrings.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(title: AppStrings.resetPassword),
      body: SafeArea(
        child: DnaPatternBackground(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spaceXXL),

                  // Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryCyan.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryCyan.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 50,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // Title
                  Center(
                    child: Text(
                      AppStrings.resetPassword,
                      style: AppTextStyles.h2,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceM),

                  Center(
                    child: Text(
                      AppStrings.resetPasswordSubtitle,
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceXXL),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          label: AppStrings.email,
                          hint: AppStrings.enterEmail,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Reset Password Button
                        Consumer<AuthViewModel>(
                          builder: (context, viewModel, child) {
                            return CustomButton(
                              text: 'Send Reset Link',
                              onPressed: _handleResetPassword,
                              isLoading: viewModel.isLoading,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
