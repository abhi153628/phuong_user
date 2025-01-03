import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/services/auth_services.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/bottom_nav_bar.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class Helo extends StatefulWidget {
  const Helo({super.key});

  @override
  State<Helo> createState() => _HeloState();
}

class _HeloState extends State<Helo> with SingleTickerProviderStateMixin {
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  final _forgotPasswordFormKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  final _forgotPasswordEmailController = TextEditingController();

  bool _isLoginPage = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _forgotPasswordEmailController.dispose();
    super.dispose();
  }

  void _togglePage() {
    setState(() {
      _animationController.reverse().then((_) {
        setState(() {
          _isLoginPage = !_isLoginPage;
        });
        _animationController.forward();
      });
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _auth.signInWithGoogle();
      if (!mounted) return;
      
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (!_forgotPasswordFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordResetLink(_forgotPasswordEmailController.text.trim());
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildForgotPasswordDialog() {
    return Dialog(
      backgroundColor: AppColorsAuth.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _forgotPasswordFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reset Password',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _forgotPasswordEmailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Send Reset Link',
                onPressed: _handleForgotPassword,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFFAFEB2B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Or continue with',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        SocialButton(
          text: 'Sign in with Google',
          iconPath: 'assets/welcomepageassets/pngwing.com.png', // Make sure to add this asset
          onPressed: _handleGoogleSignIn,
          backgroundColor: Colors.white,
          textColor: Colors.white,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final containerWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.9;
    final containerHeight = screenHeight > 800 ? 680.0 : screenHeight * 0.85;
    final containerPadding = screenWidth > 600 ? 32.0 : 24.0;
    final titleFontSize = screenWidth > 600 ? 32.0 : 28.0;
    final subtitleFontSize = screenWidth > 600 ? 16.0 : 14.0;

    return Scaffold(
      backgroundColor: AppColorsAuth.background,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 600 ? 24.0 : 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: containerWidth,
                    minHeight: screenHeight * 0.5,
                  ),
                  child: Container(
                    height: containerHeight,
                    padding: EdgeInsets.all(containerPadding),
                    decoration: BoxDecoration(
                      color: AppColorsAuth.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isLoginPage
                          ? _buildLoginPage(
                              titleSize: titleFontSize,
                              subtitleSize: subtitleFontSize,
                              spacing: screenHeight > 800 ? 40.0 : 24.0,
                            )
                          : _buildSignupPage(
                              titleSize: titleFontSize,
                              subtitleSize: subtitleFontSize,
                              spacing: screenHeight > 800 ? 32.0 : 20.0,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.activeGreen,),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPage({
    required double titleSize,
    required double subtitleSize,
    required double spacing,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome Back',
              style: GoogleFonts.poppins(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: spacing * 0.3),
            Text(
              'Please sign in to continue',
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: spacing),
            CustomTextField(
              controller: _loginEmailController,
              label: 'Email',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(height: spacing * 0.6),
            CustomTextField(
              controller: _loginPasswordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: true,
              validator: Validators.password,
              prefixIcon: Icons.lock_outlined,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _buildForgotPasswordDialog(),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFFAFEB2B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            CustomButton(
              text: 'Sign In',
              onPressed: _handleLogin,
            ),
            _buildSocialButtons(),
            const Spacer(),
            _buildToggleButton(),
          ],
        ),
      ),
    );
  }
  Future<void> _handleLogin() async {
  if (!_loginFormKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    final user = await _auth.signInWithEmailAndPassword(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text.trim(),
    );
    
    if (!mounted) return;
    
    if (user != null) {
 
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>MainScreen(),
        ),
      );
    }
  } catch (error) {
    if (!mounted) return;
    
    // Show error in SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          textColor: Colors.white,
        ),
      ),
    );
    
    // Print error for debugging
    print('Login Error: $error');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Future<void> _handleSignup() async {
    if (_signupFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.createUserEmailAndPassword(
            _signupEmailController.text, _signupPasswordController.text);
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        // ignore: use_build_context_synchronously
        Navigator.of(context)
            .push(GentlePageTransition(page:MainScreen()));
        _signupEmailController.text = '';
        _signupPasswordController.text = '';
        _signupConfirmPasswordController.text = '';
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }



  //! S I G N U P   P A G E
  Widget _buildSignupPage({
    required double titleSize,
    required double subtitleSize,
    required double spacing,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _signupFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Account',
              style: GoogleFonts.poppins(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: spacing * 0.3),
            Text(
              'Sign up to get started',
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: spacing),
            CustomTextField(
              controller: _signupEmailController,
              label: 'Email',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(height: spacing * 0.6),
            CustomTextField(
              controller: _signupPasswordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: true,
              validator: Validators.password,
              prefixIcon: Icons.lock_outlined,
            ),
            SizedBox(height: spacing * 0.6),
            CustomTextField(
              controller: _signupConfirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              obscureText: true,
              validator: (value) => Validators.confirmPassword(
                value,
                _signupPasswordController.text,
              ),
              prefixIcon: Icons.lock_outlined,
            ),
            SizedBox(height: spacing * 0.8),
            CustomButton(
              text: 'Sign Up',
              onPressed: _handleSignup,
            ),
            
            const Spacer(),
            _buildToggleButton(),
          ],
        ),
      ),
    );
  }

 

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLoginPage
              ? "Don't have an account? "
              : 'Already have an account? ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: _togglePage,
          child: Text(
            _isLoginPage ? 'Sign Up' : 'Sign In',
            style: TextStyle(
              color: Color(0xFFAFEB2B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  //* password visibility
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();

    //* Initialize obscureText with the widget's value
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: AppColorsAuth.inputBackground,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: Colors.white.withOpacity(0.7))
                : null,
            //* suffix icon for password fields
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      //* Change icon based on password visibility
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFAFEB2B)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFAFEB2B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class AppColorsAuth {
  static const background = Color(0xFF121212);
  static const surface = Colors.black;
  static const primary = Color(0xFF6C63FF); // Purple color
  static const inputBackground = Color(0xFF2D2D2D);
  static const error = Color(0xFFCF6679);
  static const success = Color(0xFF4CAF50);




}



class SocialButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const SocialButton({
    Key? key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.backgroundColor = AppColorsAuth.inputBackground,
    this.textColor = Colors.black87,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsAuth.inputBackground,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/widgets/loading_overlay.dart

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
