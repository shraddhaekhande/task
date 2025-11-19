import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/pin_login_controller.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  static const routePath = '/pin-login';

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pinLoginControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.when(
          data: (viewState) {
            if (!viewState.hasStoredPin) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PIN login unavailable on this device. Please sign in with OTP first.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(pinLoginControllerProvider.notifier)
                        .openOtp(),
                    child: const Text('Login using OTP'),
                  ),
                ],
              );
            }
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewState.hasError)
                    Text(
                      viewState.errorMessage ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: const InputDecoration(labelText: 'PIN'),
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return 'Enter your PIN';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Attempts left: ${viewState.attemptsLeft}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: viewState.canAttempt ? _onSubmit : null,
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(pinLoginControllerProvider.notifier)
                        .openOtp(),
                    child: const Text('Login using OTP'),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(pinLoginControllerProvider.notifier)
        .loginWithPin(_pinController.text.trim());
  }
}

