import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/views/login/register_step_one.dart';
import 'package:wisdomwalk/views/login/register_step_two.dart';
import 'package:wisdomwalk/views/login/register_step_three.dart';
import 'package:wisdomwalk/widgets/loading_overlay.dart';

class MultiStepRegistration extends StatefulWidget {
  const MultiStepRegistration({super.key});

  @override
  State<MultiStepRegistration> createState() => _MultiStepRegistrationState();
}

class _MultiStepRegistrationState extends State<MultiStepRegistration> {
  int _currentStep = 0;
  final Map<String, dynamic> _formData = {
    'firstName': '',
    'lastName': '',
    'email': '',
    'password': '',
    'city': '',
    'subcity': '',
    'country': '',
    'idImagePath': '',
    'faceImagePath': '', // Removed bytes
  };

  void _nextStep(Map<String, String> data) {
    setState(() {
      _formData.addAll(data);
      print(
        'Step $_currentStep -> Received data: $data, Updated _formData: $_formData',
      ); // Enhanced debug log
      if (_currentStep == 0 &&
          (_formData['firstName']?.trim().isEmpty ?? true ?? true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('First name and last name are required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
      print('Step $_currentStep -> Previous: $_formData'); // Debug log
    });
  }

  Future<void> _completeRegistration() async {
    print('Completing registration with: $_formData'); // Debug log
    if (_formData['firstName']!.trim().isEmpty ||
        _formData['lastName']!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First name and last name are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      print(
        'Sending to AuthProvider: firstName=${_formData['firstName']}, lastName=${_formData['lastName']}, email=${_formData['email']}, password=${_formData['password']}',
      ); // Debug log
      final success = await authProvider.register(
        firstName: _formData['firstName'].trim(),
        lastName: _formData['lastName'].trim(),
        email: _formData['email'].trim(),
        password: _formData['password'].trim(),
        city: _formData['city'].trim(),
        subcity: _formData['subcity'].trim(),
        country: _formData['country'].trim(),
        idImagePath: _formData['idImagePath'],
        faceImagePath: _formData['faceImagePath'],
      );

      if (success && mounted) {
        context.push('/otp', extra: {'email': _formData['email'].trim()});
      } else if (mounted && authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return LoadingOverlay(
      isLoading: authProvider.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Create an account",
            style: TextStyle(color: Color(0xFF757575)),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF757575)),
            onPressed: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                context.go('/');
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    RegisterStepOne(
                      onNext: _nextStep,
                      initialData: {
                        'firstName': _formData['firstName'],
                        'lastName': _formData['lastName'],
                        'email': _formData['email'],
                        'password': _formData['password'],
                      },
                    ),
                    RegisterStepTwo(
                      onNext: _nextStep,
                      onBack: _previousStep,
                      initialData: {
                        'city': _formData['city'],
                        'subcity': _formData['subcity'],
                        'country': _formData['country'],
                      },
                    ),
                    RegisterStepThree(
                      onComplete: (data) {
                        _formData.addAll(data);
                        _completeRegistration();
                      },
                      onBack: _previousStep,
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

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildProgressStep(0, 'Personal'),
          _buildProgressLine(0),
          _buildProgressStep(1, 'Location'),
          _buildProgressLine(1),
          _buildProgressStep(2, 'Verify'),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD4A017) : const Color(0xFFE8E2DB),
            borderRadius: BorderRadius.circular(15),
            border:
                isCurrent
                    ? Border.all(color: const Color(0xFFD4A017), width: 2)
                    : null,
          ),
          child: Center(
            child:
                isActive
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                      '${step + 1}',
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFFD4A017) : const Color(0xFF757575),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isActive = _currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFD4A017) : const Color(0xFFE8E2DB),
      ),
    );
  }
}
