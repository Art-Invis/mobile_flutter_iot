import 'package:flutter/material.dart';

void main() {
  runApp(const DexterApp());
}

class DexterApp extends StatelessWidget {
  const DexterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DarkPassengerScreen(),
    );
  }
}

class DarkPassengerScreen extends StatefulWidget {
  const DarkPassengerScreen({super.key});

  @override
  State<DarkPassengerScreen> createState() => _DarkPassengerScreenState();
}

class _DarkPassengerScreenState extends State<DarkPassengerScreen> {
  int _score = 0; 
  String _status = 'SYSTEM READY';
  IconData _icon = Icons.shield_outlined;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INTERNAL URGE MONITOR',
          style: TextStyle(
            color: Color.fromARGB(191, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: const Color.fromARGB(255, 31, 157, 199),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MIAMI METRO POLICE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  '$_score%',
                  style: TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'monospace',
                  ),
                ),
                
                Icon(_icon, size: 50, color: Colors.white70),
                const SizedBox(height: 20),

                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 60),

                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'What are yu thinking, Dexter',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
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