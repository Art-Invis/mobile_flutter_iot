import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isWide = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -screenHeight * 0.1,
            right: -screenWidth * 0.2,
            child: _buildBlurBlob(
              const Color(0xFF38BDF8).withValues(alpha: 0.12),
              screenWidth * 0.8,
            ),
          ),
          Positioned(
            bottom: -screenHeight * 0.1,
            left: -screenWidth * 0.2,
            child: _buildBlurBlob(
              const Color(0xFF4ADE80).withValues(alpha: 0.08),
              screenWidth * 0.9,
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: isWide ? 200 : 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'USER PROFILE',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: isWide ? 24 : 16,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? screenWidth * 0.2 : 24,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Center(child: _buildAvatar(isWide)),
                    const SizedBox(height: 24),
                    Text(
                      'Artem Dev',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isWide ? 32 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'System Administrator',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                    const SizedBox(height: 40),

                    GlassCard(
                      child: Column(
                        children: [
                          _buildProfileOption(
                            Icons.notifications_active_outlined,
                            'Push Notifications',
                            true,
                            value: _notifications,
                            onChanged: (val) =>
                                setState(() => _notifications = val),
                          ),
                          const Divider(color: Colors.white10),
                          _buildProfileOption(
                            Icons.dark_mode_outlined,
                            'Dark Mode',
                            true,
                            value: _darkMode,
                            onChanged: (val) => setState(() => _darkMode = val),
                          ),
                          const Divider(color: Colors.white10),
                          _buildProfileOption(
                            Icons.language_outlined,
                            'Language',
                            false,
                            trailingText: 'EN',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/'),
                        leading: const Icon(
                          Icons.logout,
                          color: Color(0xFFF87171),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Color(0xFFF87171)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50), // Відступ знизу для зручності
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Допоміжний віджет аватара
  Widget _buildAvatar(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF4ADE80)],
        ),
      ),
      child: CircleAvatar(
        radius: isWide ? 80 : 60,
        backgroundColor: const Color(0xFF1E293B),
        child: Icon(Icons.person, size: isWide ? 80 : 60, color: Colors.white),
      ),
    );
  }

  // Функція для фонових плям
  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    bool isSwitch, {
    String? trailingText,
    bool value = false,
    void Function(bool)? onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF38BDF8)),
      title: Text(title),
      trailing: isSwitch
          ? Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF38BDF8),
            )
          : Text(
              trailingText ?? '',
              style: const TextStyle(color: Colors.white38),
            ),
    );
  }
}
