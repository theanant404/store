import 'dart:async';

import 'package:flutter/material.dart';
import 'package:store/features/auth/data/auth_api.dart';
import 'package:store/features/auth/data/session_store.dart';

class LoginWithOtpPage extends StatefulWidget {
  const LoginWithOtpPage({super.key});

  @override
  State<LoginWithOtpPage> createState() => _LoginWithOtpPageState();
}

class _LoginWithOtpPageState extends State<LoginWithOtpPage> {
  final _otpController = TextEditingController();
  final _authApi = AuthApi();
  bool _isSendingOtp = false;
  bool _isVerifying = false;
  bool _hydratedFromArgs = false;
  String? _identifier; // phone/email passed from previous screen
  Timer? _resendTimer;
  int _resendSeconds = 30;

  bool _looksLikeEmail(String value) => value.contains('@');

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydratedFromArgs) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) {
      _identifier = arg;
      _startResendTimer();
    }
    _hydratedFromArgs = true;
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
      } else {
        if (mounted) setState(() => _resendSeconds -= 1);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if ((_identifier == null || _identifier!.isEmpty) || otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() => _isVerifying = true);
    try {
      if (_looksLikeEmail(_identifier!)) {
        await _authApi.loginWithOtp(email: _identifier!, otp: otp);
      } else {
        await _authApi.verifyOtp(email: _identifier!, otp: otp);
      }

      if (!mounted) return;
      final derivedName = _looksLikeEmail(_identifier!)
          ? _identifier!.split('@').first
          : _identifier!;
      SessionStore.setUser(
        UserSession.basic(name: derivedName, email: _identifier!),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP verified, logged in')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP verification failed: $e')));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_identifier == null || _identifier!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No identifier available to send OTP')),
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    try {
      if (_looksLikeEmail(_identifier!)) {
        await _authApi.sendEmailOtp(email: _identifier!);
      } else {
        await _authApi.sendOtp(email: _identifier!);
      }
      if (!mounted) return;
      _startResendTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP resent')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to resend OTP: $e')));
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Login with OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sms_rounded,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Verify your email/phone',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Enter the code we sent to your contact',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_identifier != null && _identifier!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.mark_email_read, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Code sent to $_identifier',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_identifier != null && _identifier!.isNotEmpty)
                      const SizedBox(height: 16),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        prefixIcon: const Icon(Icons.numbers),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isVerifying ? null : _verifyOtp,
                        child: _isVerifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Verify & Login'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: (_isSendingOtp || _resendSeconds > 0)
                            ? null
                            : _resendOtp,
                        child: _isSendingOtp
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _resendSeconds > 0
                                    ? 'Resend in ${_resendSeconds}s'
                                    : 'Resend OTP',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
