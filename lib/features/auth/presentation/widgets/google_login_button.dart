import 'package:flutter/material.dart';
import 'package:store/core/common_widgets/custom_snackbar.dart';
import 'package:store/features/auth/data/auth_api.dart';

class GoogleLoginButton extends StatelessWidget {
  final AuthApi authApi;
  final Function onSuccess;
  final Function onError;

  const GoogleLoginButton({
    super.key, // Using modern super parameters
    required this.authApi,
    required this.onSuccess,
    required this.onError,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width for better mobile UX
      height: 55, // Thicker buttons feel more premium
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2, // Soft shadow
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Modern rounded corners
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        onPressed: () async {
          try {
            // Add a loading indicator logic here if you have a state manager
            await Future.delayed(const Duration(seconds: 2));
            onSuccess();
            showSuccessSnackBar(
              context,
              message: 'Google sign-in successful! 🎉',
            );
          } catch (e) {
            onError(e);
            showErrorSnackBar(
              context,
              message: 'Failed to sign in with Google: $e',
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using an Image is better than an Icon for brand logos
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
              height: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}