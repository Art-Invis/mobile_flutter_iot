import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/profile_item.dart';

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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: BlurBlob(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.06),
              size: size.width * 0.8,
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: BlurBlob(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.05),
              size: size.width * 0.9,
            ),
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
                    const SizedBox(height: 40),
                    _buildSettingsGroup(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isWide) => SliverAppBar(
    expandedHeight: isWide ? 150 : 100,
    pinned: true,
    backgroundColor: Colors.transparent,
    
    flexibleSpace: const FlexibleSpaceBar(
      centerTitle: true,
      title: Text('USER PROFILE', style: TextStyle(letterSpacing: 2)),
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
          radius: isWide ? 80 : 60,
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(
            Icons.person,
            size: isWide ? 80 : 60,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Artem Dev',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      const Text(
        'System Administrator',
        style: TextStyle(color: Colors.white38),
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
          trailingText: 'Lad-605a',
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
      onTap: () => Navigator.pushReplacementNamed(context, '/'),
      leading: const Icon(Icons.logout, color: Color(0xFFF87171)),
      title: const Text('Logout', style: TextStyle(color: Color(0xFFF87171))),
    ),
  );
}
