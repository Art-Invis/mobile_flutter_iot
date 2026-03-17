import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
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

  UserModel? _currentUser;
  final _userRepository = LocalUserRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userRepository.getUser();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = user;
      _isAutoLoginEnabled = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF87171)),
            SizedBox(width: 10),
            Text('System Purge', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will permanently erase your encryption keys, saved devices, and local profile. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF87171).withValues(alpha: 0.2),
                foregroundColor: const Color(0xFFF87171),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFF87171)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('CONFIRM PURGE'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userRepository.deleteUser();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> _editProfileField(
    String title,
    String currentValue,
    void Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: currentValue);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update $title',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new $title',
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF38BDF8)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(context);
                _loadUserData();
              }
            },
            child: const Text(
              'Save Changes',
              style: TextStyle(color: Color(0xFF38BDF8)),
            ),
          ),
        ],
      ),
    );
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
            physics: const BouncingScrollPhysics(),
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
                    const Text(
                      'PREFERENCES',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(),
                    const SizedBox(height: 32),
                    const Text(
                      'ACCOUNT ACTIONS',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
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

  Widget _buildAppBar(bool isWide) => SliverAppBar(
    expandedHeight: isWide ? 150 : 100,
    pinned: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: const FlexibleSpaceBar(
      centerTitle: true,
      title: Text(
        'USER PROFILE',
        style: TextStyle(
          letterSpacing: 2,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _buildHeader(bool isWide) {
    final name = _currentUser?.fullName ?? 'Loading...';
    final dept = _currentUser?.department ?? 'Unknown Department';
    final email = _currentUser?.email ?? 'no-email@system.io';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF38BDF8).withValues(alpha: 0.5),
                const Color(0xFF4ADE80).withValues(alpha: 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: isWide ? 70 : 55,
            backgroundColor: const Color(0xFF0F172A),
            child: CircleAvatar(
              radius: isWide ? 66 : 51,
              backgroundColor: const Color(0xFF1E293B),
              child: Icon(
                Icons.person_rounded,
                size: isWide ? 70 : 50,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _editProfileField('Full Name', name, (val) async {
            if (_currentUser != null) {
              final updated = UserModel(
                fullName: val,
                email: _currentUser!.email,
                password: _currentUser!.password,
                department: _currentUser!.department,
              );
              await _userRepository.saveUser(updated);
            }
          }),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dept.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF4ADE80),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _editProfileField('Email', email, (val) async {
            if (val.contains('@') && _currentUser != null) {
              final updated = UserModel(
                fullName: _currentUser!.fullName,
                email: val,
                password: _currentUser!.password,
                department: _currentUser!.department,
              );
              await _userRepository.saveUser(updated);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              email,
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityStatus() => GlassCard(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isAutoLoginEnabled
                ? const Color(0xFF4ADE80).withValues(alpha: 0.1)
                : Colors.orangeAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isAutoLoginEnabled
                ? Icons.verified_user_rounded
                : Icons.shield_moon_outlined,
            color: _isAutoLoginEnabled
                ? const Color(0xFF4ADE80)
                : Colors.orangeAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Protocol',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              _isAutoLoginEnabled
                  ? 'Persistent Session: Active'
                  : 'Session Encryption: Local Only',
              style: const TextStyle(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSettingsGroup() => GlassCard(
    child: Column(
      children: [
        ProfileMenuItem(
          icon: Icons.notifications_active_outlined,
          title: 'System Alerts',
          isSwitch: true,
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
        ),
        const Divider(color: Colors.white10, height: 1),
        ProfileMenuItem(
          icon: Icons.palette_outlined,
          title: 'OLED Dark Mode',
          isSwitch: true,
          value: _darkMode,
          onChanged: (v) => setState(() => _darkMode = v),
        ),
        const Divider(color: Colors.white10, height: 1),
        ProfileMenuItem(
          icon: Icons.hub_outlined,
          title: 'Department Unit',
          trailingText: _currentUser?.department ?? '...',
          onTap: () => _editProfileField(
            'Department',
            _currentUser?.department ?? '',
            (val) async {
              if (_currentUser != null) {
                final updated = UserModel(
                  fullName: _currentUser!.fullName,
                  email: _currentUser!.email,
                  password: _currentUser!.password,
                  department: val,
                );
                await _userRepository.saveUser(updated);
                _loadUserData();
              }
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildActionButtons(BuildContext context) => Column(
    children: [
      GlassCard(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          leading: const Icon(Icons.logout, color: Color(0xFFF87171)),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFFF87171),
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.white24,
          ),
        ),
      ),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: _deleteAccount,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFF87171).withValues(alpha: 0.3),
            ),
            color: const Color(0xFFF87171).withValues(alpha: 0.05),
          ),
          child: const Center(
            child: Text(
              'DELETE ACCOUNT ',
              style: TextStyle(
                color: Color(0xFFF87171),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
