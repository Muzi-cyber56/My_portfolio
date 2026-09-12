import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  const LoginScreen({super.key, required this.onSignedIn});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>(),
      _username = TextEditingController(),
      _password = TextEditingController();
  bool _register = false, _busy = false, _hidden = true;
  String? _error;
  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.instance.authenticate(
        _username.text.trim(),
        _password.text,
        _register,
      );
      if (mounted) widget.onSignedIn();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, c) => Row(
        children: [
          if (c.maxWidth > 950)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(64),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF132951), AppConfig.background],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.radar, color: AppConfig.blue, size: 35),
                        SizedBox(width: 12),
                        Text(
                          'SENTINEL',
                          style: TextStyle(
                            letterSpacing: 5,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.hub_outlined,
                      size: 105,
                      color: AppConfig.blue,
                    ),
                    const SizedBox(height: 38),
                    const Text(
                      'Every detail.\nA clearer picture.',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'A focused workspace for open-source intelligence\nand digital evidence. From the first lead to the final report.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConfig.muted,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Chip(label: Text('OSINT research')),
                        Chip(label: Text('Evidence integrity')),
                        Chip(label: Text('Case reports')),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      'INVESTIGATE WITH CLARITY',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 3,
                        color: AppConfig.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.radar,
                            color: AppConfig.blue,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _register ? 'Create your workspace' : 'Welcome back',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _register
                              ? 'Set up an analyst account to begin.'
                              : 'Sign in to your investigation workspace.',
                          style: const TextStyle(color: AppConfig.muted),
                        ),
                        const SizedBox(height: 34),
                        TextFormField(
                          controller: _username,
                          validator: Validators.title,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                            counterText: '',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _password,
                          validator: Validators.password,
                          obscureText: _hidden,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: 'Show or hide password',
                              onPressed: () =>
                                  setState(() => _hidden = !_hidden),
                              icon: Icon(
                                _hidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (_) => _busy ? null : _submit(),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'At least 12 characters',
                          style: TextStyle(
                            color: AppConfig.muted,
                            fontSize: 12,
                          ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Text(_error!),
                          ),
                        const SizedBox(height: 26),
                        CustomButton(
                          label: _register ? 'Create account' : 'Sign in',
                          onPressed: _submit,
                          busy: _busy,
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _register = !_register;
                                  _error = null;
                                }),
                          child: Text(
                            _register
                                ? 'Already have an account? Sign in'
                                : 'New analyst? Create an account',
                          ),
                        ),
                        const SizedBox(height: 36),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 15,
                              color: AppConfig.muted,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Private cases. Traceable evidence.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConfig.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
