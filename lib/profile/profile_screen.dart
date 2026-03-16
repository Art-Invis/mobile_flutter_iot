import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/profile_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _darkMode = true;
  bool _isAutoLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSessionStatus();
  }

  Future<void> _loadSessionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAutoLoginEnabled = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BlurBlob(
            alignment: Alignment.topRight,
            translation: const Offset(0.3, -0.3),
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            size: size.width * 0.7,
          ),
          BlurBlob(
            alignment: Alignment.bottomLeft,
            translation: const Offset(-0.3, 0.3),
            color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
            size: size.width * 0.8,
          ),

          CustomScrollView(
            slivers: [
              _buildAppBar(isWide),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? size.width * 0.2 : 24,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(isWide),
                    const SizedBox(height: 32),

                    _buildSecurityStatus(),

                    const SizedBox(height: 24),
                    _buildSettingsGroup(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus() => GlassCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Icon(
          _isAutoLoginEnabled ? Icons.verified_user : Icons.gpp_maybe,
          color: _isAutoLoginEnabled
              ? const Color(0xFF4ADE80)
              : Colors.orangeAccent,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Security',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              _isAutoLoginEnabled
                  ? 'Auto-login active (Web LocalStorage)'
                  : 'Session not saved',
              style: const TextStyle(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildAppBar(bool isWide) => SliverAppBar(
    expandedHeight: isWide ? 150 : 100,
    pinned: true,
    backgroundColor: Colors.transparent,
    flexibleSpace: const FlexibleSpaceBar(
      centerTitle: true,
      title: Text(
        'USER PROFILE',
        style: TextStyle(letterSpacing: 2, fontSize: 16),
      ),
    ),
  );

  Widget _buildHeader(bool isWide) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFF4ADE80)],
          ),
        ),
        child: CircleAvatar(
          radius: isWide ? 70 : 50,
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(
            Icons.person,
            size: isWide ? 70 : 50,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Artem Dev',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const Text(
        'System Administrator',
        style: TextStyle(color: Colors.white38, fontSize: 13),
      ),
    ],
  );

  Widget _buildSettingsGroup() => GlassCard(
    child: Column(
      children: [
        ProfileMenuItem(
          icon: Icons.notifications_none,
          title: 'Push Notifications',
          isSwitch: true,
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
        ),
        const Divider(color: Colors.white10),
        ProfileMenuItem(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          isSwitch: true,
          value: _darkMode,
          onChanged: (v) => setState(() => _darkMode = v),
        ),
        const Divider(color: Colors.white10),
        const ProfileMenuItem(
          icon: Icons.devices_other,
          title: 'WorkSpace',
          trailingText: 'Lab-605a',
        ),
        const Divider(color: Colors.white10),
        const ProfileMenuItem(
          icon: Icons.language,
          title: 'Language',
          trailingText: 'EN',
        ),
      ],
    ),
  );

  Widget _buildLogoutButton(BuildContext context) => GlassCard(
    padding: EdgeInsets.zero,
    child: ListTile(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      leading: const Icon(Icons.logout, color: Color(0xFFF87171)),
      title: const Text(
        'Logout',
        style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        'Clears local session data',
        style: TextStyle(fontSize: 10, color: Colors.white24),
      ),
    ),
  );
}
