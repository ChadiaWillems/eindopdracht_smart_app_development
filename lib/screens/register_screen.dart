import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/generic/generic_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty &&
        _emailController.text.isEmpty &&
        _passwordController.text.isEmpty &&
        _confirmPasswordController.text.isEmpty) {
      _showError("Vul alstublieft alle velden in.");
      return;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Wachtwoorden komen niet overeen.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Maak de gebruiker aan in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Maak het profiel aan in de 'users' collectie in Firestore
      if (userCredential.user != null) {
        await _firestoreService.createUserProfile(
          userCredential.user!.uid,
          _nameController.text.trim(),
          _emailController.text.trim(),
        );
      }

      print("Registratie succesvol: ${userCredential.user?.email}");

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Er is iets misgegaan.");
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
        title: const Text('Registratie mislukt'),
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Account aanmaken'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text("Naam", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Bijv. Jan Janssen',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "E-mail",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'jouw@email.com',
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
                placeholder: 'Minimaal 6 tekens',
                obscureText: true,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Bevestig wachtwoord",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _confirmPasswordController,
                placeholder: 'Bevestig je wachtwoord',
                obscureText: true,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : GenericButton(
                        label: 'Registreren',
                        onPressed: _handleRegister,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
