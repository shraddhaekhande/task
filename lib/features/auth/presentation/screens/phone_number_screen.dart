import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../application/phone_auth_controller.dart';

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  static const routePath = '/phone';

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _completeNumber;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneAuthControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter phone number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) => _completeNumber = phone.completeNumber,
                validator: (value) {
                  if (value == null || value.completeNumber.isEmpty) {
                    return 'Enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              state.when(
                data: (_) => ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Continue'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, __) => Column(
                  children: [
                    Text(
                      err.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _onSubmit,
                      child: const Text('Retry'),
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

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final phone = _completeNumber;
    if (phone == null) return;
    await ref
        .read(phoneAuthControllerProvider.notifier)
        .requestOtp(phoneNumber: phone);
  }
}

