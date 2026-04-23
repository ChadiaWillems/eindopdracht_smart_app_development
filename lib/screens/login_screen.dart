import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/register_screen.dart';
import 'package:medscan/widgets/generic/generic_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Vul alstublieft alle velden in.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = "Dit e-mailadres is niet bekend.";
        }
        else if (e.code == 'wrong-password') {
          _errorMessage = "Het wachtwoord is onjuist.";
        }
        else if (e.code == 'invalid-credential') {
          _errorMessage = "E-mailadres of wachtwoord is onjuist.";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "Dit is geen geldig e-mailadres.";
        } else {
          _errorMessage = "Inloggen mislukt: ${e.message}";
        }
      });
    } catch (e) {
      setState(() => _errorMessage = "Er is een onverwachte fout opgetreden.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Inloggen')),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "E-mailadres",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'voorbeeld@mail.com',
                  keyboardType: TextInputType.emailAddress,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: _errorMessage != null
                        ? Border.all(
                            color: CupertinoColors.destructiveRed.withOpacity(
                              0.5,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Wachtwoord",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Je wachtwoord',
                  obscureText: true,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: _errorMessage != null
                        ? Border.all(
                            color: CupertinoColors.destructiveRed.withOpacity(
                              0.5,
                            ),
                          )
                        : null,
                  ),
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CupertinoColors.destructiveRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),
                Center(
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : GenericButton(
                          label: 'Inloggen',
                          onPressed: _handleLogin,
                        ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CupertinoButton(
                    child: const Text('Nog geen account? Registreer hier'),
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
