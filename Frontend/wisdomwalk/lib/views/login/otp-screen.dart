import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/widgets/loading_overlay.dart';
import 'package:auto_size_text/auto_size_text.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((controller) => controller.text).join();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOtp(email: widget.email, otp: otp);

    if (success && mounted) {
      context.go('/login');
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendOtp(email: widget.email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent'),
          backgroundColor: Color(0xFF4A4A4A),
        ),
      );
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return LoadingOverlay(
      isLoading: authProvider.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Verify Email",
            style: TextStyle(color: Color(0xFF757575)),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF757575)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05, // 5% of screen width
                  vertical: screenHeight * 0.02, // 2% of screen height
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: screenWidth * 0.15, // Responsive icon size
                        color: const Color(0xFFD4A017),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Email Verification',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A4A4A),
                          fontFamily: 'Playfair Display',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'We\'ve sent a verification code to\n${widget.email}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: const Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      _buildOtpFields(screenWidth),
                      SizedBox(height: screenHeight * 0.05),
                      _buildVerifyButton(screenWidth),
                      SizedBox(height: screenHeight * 0.03),
                      _buildResendCode(screenWidth),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: screenWidth * 0.15,
          height: screenWidth * 0.15,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8E2DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD4A017)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: screenWidth * 0.14, // Increased height for better text fit
      child: ElevatedButton(
        onPressed: _isAllFieldsFilled() ? _verifyOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4A017),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFD4A017).withOpacity(0.5),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Responsive padding
            vertical: screenWidth * 0.03,
          ),
        ),
        child: AutoSizeText(
          'Verify',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          minFontSize: 12,
          maxFontSize: 16,
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildResendCode(double screenWidth) {
    return TextButton(
      onPressed: _resendOtp,
      child: Text(
        'Didn\'t receive a code? Resend',
        style: TextStyle(
          color: const Color(0xFFD4A017),
          fontSize: screenWidth * 0.035,
        ),
      ),
    );
  }

  bool _isAllFieldsFilled() {
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }
}
