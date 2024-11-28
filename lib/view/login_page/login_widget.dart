// File: login_widgets.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/signup_page/signup_page.dart';
import 'package:phuong/view/welcomepage/welcomes_screen.dart';

class BackgroundImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: const AssetImage(
                  "assets/welcomepageassets/crowd-people-with-raised-arms-having-fun-music-festival-by-night.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.9), BlendMode.dstATop),
            ),
          ),
        ),
      ),
    );
  }
}

class BlackOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Opacity(
        opacity: 0.1,
        child: Container(
          height: 710,
          color: Colors.black,
        ),
      ),
    );
  }
}

class BrandName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 140),
          child: Text(
            'Phuong',
            style: GoogleFonts.greatVibes(
                fontSize: 35, color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final Size mediaSize;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberUser;
  final Function(bool) onRememberChanged;
  final VoidCallback onLogin;

  const LoginForm({
    Key? key,
    required this.mediaSize,
    required this.emailController,
    required this.passwordController,
    required this.rememberUser,
    required this.onRememberChanged,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      top: 190,
      child: SizedBox(
        width: mediaSize.width,
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: LoginFormContent(
              emailController: emailController,
              passwordController: passwordController,
              rememberUser: rememberUser,
              onRememberChanged: onRememberChanged,
              onLogin: onLogin,
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFormContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberUser;
  final Function(bool) onRememberChanged;  
  final VoidCallback onLogin;

  const LoginFormContent({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.rememberUser,
    required this.onRememberChanged,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Welcome",
              style: GoogleFonts.philosopher(
                  color: const Color(0xFF7A491C), fontSize: 30)),
          _buildGreyText("Please login with your information"),
          const SizedBox(height: 30),
          _buildGreyText("Email address"),
          _buildInputField(emailController),
          const SizedBox(height: 40),
          _buildGreyText("Password"),
          _buildInputField(passwordController, isPassword: true),
          const SizedBox(height: 10),
          _buildRememberForgot(),
          const SizedBox(height: 20),
          _buildLoginButton(),
          const SizedBox(height: 20),
          _buildOtherLogin(context),
        ],
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color.fromARGB(255, 1, 1, 1)),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? const Icon(Icons.remove_red_eye)
            : const Icon(Icons.done),
      ),
      obscureText: isPassword,
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
                value: rememberUser,
                onChanged: (value) => onRememberChanged(value!)),
            _buildGreyText("Remember me"),
          ],
        ),
        TextButton(
            onPressed: () {}, child: _buildGreyText("I forgot my password"))
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: onLogin,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        shadowColor: const Color(0xFF7A491C),
        minimumSize: const Size.fromHeight(60),
      ),
      child: Text(
        "Login",
        style: GoogleFonts.aBeeZee(
            color: const Color.fromARGB(255, 0, 0, 0), fontSize: 20),
      ),
    );
  }

  Widget _buildOtherLogin(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildGreyText(
              "---------------------------Or Login with--------------------------"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(GentlePageTransition(page: const WelcomesScreen(), child: null));
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: const Color(0xFF7A491C),
              minimumSize: const Size.fromHeight(60),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/welcomepageassets/pngwing.com.png',
                  height: 24.0,
                ),
                const SizedBox(width: 8),
                Text(
                  "Google",
                  style: GoogleFonts.aBeeZee(
                      color: const Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  "Don't have an account?",
                  style: GoogleFonts.aBeeZee(
                      color: const Color.fromARGB(255, 0, 0, 0), fontSize: 15),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(GentlePageTransition(page: const SignupPage(), child: null));
                  },
                  child: const Text('Sign up'))
            ],
          ),
        ],
      ),
    );
  }
}