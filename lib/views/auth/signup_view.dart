import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/logo_widget.dart';
import '../../core/widgets/dna_pattern_background.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/dialog_helper.dart';
import '../../routes/app_router.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();

    final success = await viewModel.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      AppRouter.navigateToHome(context);
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
                  const SizedBox(height: 60),

                  // Logo
                  const Center(child: LogoWidget(size: 80)),

                  const SizedBox(height: AppDimensions.spaceXXL),

                  // Title
                  const Text(AppStrings.createAccount, style: AppTextStyles.h1),

                  const SizedBox(height: AppDimensions.spaceS),

                  Text(
                    AppStrings.signUpSubtitle,
                    style: AppTextStyles.bodySecondary,
                  ),

                  const SizedBox(height: AppDimensions.spaceXXL),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field
                        CustomTextField(
                          controller: _nameController,
                          label: AppStrings.fullName,
                          hint: AppStrings.enterFullName,
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateName,
                        ),

                        const SizedBox(height: AppDimensions.spaceL),

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          label: AppStrings.email,
                          hint: AppStrings.enterEmail,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),

                        const SizedBox(height: AppDimensions.spaceL),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: AppStrings.password,
                          hint: AppStrings.enterPassword,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.iconPrimary,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceL),

                        // Confirm Password Field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: AppStrings.confirmPassword,
                          hint: AppStrings.reEnterPassword,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.iconPrimary,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Sign Up Button
                        Consumer<AuthViewModel>(
                          builder: (context, viewModel, child) {
                            return CustomButton(
                              text: AppStrings.signUp,
                              onPressed: _handleSignup,
                              isLoading: viewModel.isLoading,
                            );
                          },
                        ),

                        const SizedBox(height: AppDimensions.spaceL),

                        // Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.alreadyHaveAccount,
                              style: AppTextStyles.bodySecondarySmall,
                            ),
                            GestureDetector(
                              onTap: () => AppRouter.navigateToLogin(context),
                              child: const Text(
                                AppStrings.signIn,
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spaceXL),
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
