import 'package:flutter/material.dart';

void main() {
  runApp(const DexterApp());
}

class DexterApp extends StatelessWidget {
  const DexterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DarkPassengerScreen(),
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
  Color _bgColor = const Color.fromARGB(255, 31, 157, 199);
  String _status = 'SYSTEM READY';
  IconData _icon = Icons.shield_outlined;

  final Set<String> _usedWords = {};
  final TextEditingController _controller = TextEditingController();

  final List<String> _darkList = ['blood', 'knife', 'kill', 'dark', 'body'];
  final List<String> _safeList = ['son', 'donut', 'sister', 'work', 'family'];

  void _analyze(String input) {
    final String text = input.trim().toLowerCase();

    if (text.contains('doakes')) {
      _resetAll('SURPRISE, MOTHERF***ER!', Colors.orangeAccent, Icons.warning);
      return;
    }

    if (text.isEmpty) return;

    final List<String> words = text.split(RegExp(r'\s+'));

    setState(() {
      for (var word in words) {
        if (!_usedWords.contains(word)) {
          if (_darkList.contains(word)) {
            _score += 20;
            _usedWords.add(word);
          } else if (_safeList.contains(word)) {
            _score -= 20;
            _usedWords.add(word);
          }
        }
      }

      _score = _score.clamp(0, 100);

      if (_score >= 100) {
        _bgColor = const Color(0xFF700000);
        _status = 'DARK PASSENGER ACTIVE';
        _icon = Icons.dangerous;
      } else if (_score > 0) {
        _bgColor = Color.lerp(
          const Color.fromARGB(255, 30, 40, 50),
          Colors.redAccent[700],
          _score / 100,
        )!;
        _status = 'DARK PASSENGER IS CLOSE...';
        _icon = Icons.visibility;
      } else if (_score == 0) {
        _bgColor = const Color.fromARGB(255, 76, 178, 212);
        _status = 'NORMAL GUY';
        _icon = Icons.emoji_emotions;
      } else {
        _bgColor = const Color.fromARGB(255, 31, 157, 199);
        _status = 'SYSTEM READY';
        _icon = Icons.shield_outlined;
      }
    });
  }

  void _resetAll(String msg, Color color, IconData icon) {
    setState(() {
      _score = 0;
      _usedWords.clear();
      _controller.clear();
      _status = msg;
      _bgColor = color;
      _icon = icon;
    });
  }

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
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _bgColor,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MIAMI METRO POLICE',
                  style: TextStyle(
                    color: Color.fromARGB(224, 255, 255, 255),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 20),
                const Icon(
                  Icons.local_police,
                  size: 50,
                  color: Color.fromARGB(225, 255, 254, 254),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 10),
                Container(height: 1, width: 100, color: Colors.white24),
                const SizedBox(height: 40),

                Text(
                  '$_score%',
                  style: TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.9),
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
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 60),

                TextField(
                  controller: _controller,
                  onChanged: _analyze,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'What are you thinking, Dexter?',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black38,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.psychology_outlined,
                      color: Colors.white38,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                TextButton.icon(
                  onPressed: () => _resetAll(
                    'SYSTEM READY',
                    const Color.fromARGB(255, 31, 157, 199),
                    Icons.shield_outlined,
                  ),
                  icon: const Icon(
                    Icons.refresh,
                    color: Color.fromARGB(179, 0, 0, 0),
                  ),
                  label: const Text(
                    'RESET LOGS',
                    style: TextStyle(
                      color: Color.fromARGB(166, 0, 0, 0),
                      fontWeight: FontWeight.bold,
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
