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

  Future<void> _handleLogin() async {
    // 1. Check of velden leeg zijn
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Vul aalstublieft je e-mail en wachtwoord in.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Inloggen bij Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Succes! Terug naar waar we vandaan kwamen (het medicijn scherm)
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Foutmeldingen vertalen naar NL
      String errorMsg = "Er is iets misgegaan.";
      if (e.code == 'user-not-found')
        errorMsg = "Geen gebruiker gevonden met dit e-mailadres.";
      if (e.code == 'wrong-password') errorMsg = "Onjuist wachtwoord.";
      if (e.code == 'invalid-email')
        errorMsg = "Dit is geen geldig e-mailadres.";

      _showError(errorMsg);
    } catch (e) {
      _showError("Fout: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Inloggen mislukt'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Inloggen')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
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
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : GenericButton(label: 'Inloggen', onPressed: _handleLogin),
              ),
              SizedBox(height: 20),
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
    );
  }
}
