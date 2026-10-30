import 'dart:math';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({Key? key}) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = SupabaseService().userName ?? '';
  }

  String _generateRandomCode() {
    final rand = Random();
    final num = 1000 + rand.nextInt(9000);
    return 'LOVE-$num';
  }

  Future<void> _handleConnect(String code) async {
    final name = _nameController.text.trim().isEmpty ? 'Partner' : _nameController.text.trim();
    final cleanCode = code.trim().toUpperCase();

    if (cleanCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or generate a couple code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await SupabaseService().savePairing(code: cleanCode, name: name);
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5E7E).withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 72,
                  color: Color(0xFFFF5E7E),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SyncAlarm for Couples',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set an alarm on your phone, and it automatically rings on hers too ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your Name or Nickname',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'e.g. Babe, Alex',
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFFF5E7E)),
                  filled: true,
                  fillColor: const Color(0xFF1E1B2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Option 1: Generate Code
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF5E7E).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Option 1: Create New Couple Space',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Generate a code and send it to your partner',
                      style: TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        final code = _generateRandomCode();
                        _handleConnect(code);
                      },
                      icon: const Icon(Icons.add_link, color: Colors.white),
                      label: const Text(
                        'Generate Code & Start',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5E7E),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Option 2: Join with Partner's Code
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Option 2: Join Partner',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the code shown on her phone',
                      style: TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'e.g. LOVE-8472',
                        hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 0),
                        filled: true,
                        fillColor: const Color(0xFF13111C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _handleConnect(_codeController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.12),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Connect Phones',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
