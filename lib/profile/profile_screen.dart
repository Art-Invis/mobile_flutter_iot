import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/providers/auth_provider.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/profile_item.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _darkMode = true;

  UserModel? _currentUser;
  final _userRepository = LocalUserRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userRepository.getUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'System Termination',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);

                Navigator.pop(dialogContext);

                await auth.logout();

                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: const Text('LOGOUT',
                  style: TextStyle(color: Colors.redAccent),),
            ),
          ],
        );
      },
    );
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
          'This will permanently erase your encryption keys '
          'and local profile. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF87171).withValues(alpha: 0.2),
              foregroundColor: const Color(0xFFF87171),
              side: const BorderSide(color: Color(0xFFF87171)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM PURGE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userRepository.deleteUser();
      if (mounted) {
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _editProfileField(
    String title,
    String currentValue,
    void Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: currentValue);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            Text('Update $title', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new $title',
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
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
              onSave(controller.text);
              Navigator.pop(context);
              _loadUserData();
            },
            child:
                const Text('Save', style: TextStyle(color: Color(0xFF38BDF8))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = context.watch<AuthProvider>();

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
              const SliverAppBar(
                expandedHeight: 100,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
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
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildSecurityStatus(auth.isLoggedIn),
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
                    _buildActionButtons(),
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

  Widget _buildHeader() {
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
            ),
          ),
          child: const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFF0F172A),
            child: CircleAvatar(
              radius: 51,
              backgroundColor: Color(0xFF1E293B),
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
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
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dept.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF4ADE80),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _editProfileField('Email', email, (val) async {
            if (_currentUser != null) {
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
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityStatus(bool isActive) => GlassCard(
        child: Row(
          children: [
            Icon(
              isActive
                  ? Icons.verified_user_rounded
                  : Icons.shield_moon_outlined,
              color: isActive ? const Color(0xFF4ADE80) : Colors.orangeAccent,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security Protocol',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isActive
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
            const Divider(color: Colors.white10),
            ProfileMenuItem(
              icon: Icons.palette_outlined,
              title: 'OLED Dark Mode',
              isSwitch: true,
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            const Divider(color: Colors.white10),
            ProfileMenuItem(
              icon: Icons.hub_outlined,
              title: 'Department Unit',
              trailingText: _currentUser?.department ?? '...',
              onTap: () => _editProfileField(
                  'Department', _currentUser?.department ?? '', (val) async {
                if (_currentUser != null) {
                  final updated = UserModel(
                    fullName: _currentUser!.fullName,
                    email: _currentUser!.email,
                    password: _currentUser!.password,
                    department: val,
                  );
                  await _userRepository.saveUser(updated);
                }
              }),
            ),
          ],
        ),
      );

  Widget _buildActionButtons() => Column(
        children: [
          GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: _showLogoutDialog,
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
                  'DELETE ACCOUNT',
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
