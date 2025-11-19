import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/pin_setup_controller.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  static const routePath = '/set-pin';

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pinSetupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set secure PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'Enter PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: _validatePin,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(labelText: 'Confirm PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value != _pinController.text) {
                    return 'PINs do not match';
                  }
                  return _validatePin(value);
                },
              ),
              const SizedBox(height: 24),
              state.when(
                data: (_) => ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Save PIN'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, __) => Column(
                  children: [
                    Text(
                      err.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
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

  String? _validatePin(String? value) {
    if (value == null || value.length < 4) {
      return 'PIN must be at least 4 digits';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(pinSetupControllerProvider.notifier)
        .setPin(_pinController.text.trim());
  }
}

