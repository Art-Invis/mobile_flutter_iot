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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "INTERNAL URGE MONITOR",
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MIAMI METRO POLICE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 20),
              Icon(Icons.local_police, size: 50, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}