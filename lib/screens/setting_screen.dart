import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'personal_info_screen.dart';
import 'screen_time_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSettingsSection(
              title: 'Account Settings',
              items: [
                _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.security_rounded,
                  title: 'Security & Password',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              title: 'Child Devices',
              items: [
                _SettingsItem(
                  icon: Icons.devices_rounded,
                  title: 'Manage Connected Devices',
                  subtitle: '1 Device Active',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.schedule_rounded,
                  title: 'Screen Time Limits',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScreenTimeScreen()),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.app_blocking_outlined,
                  title: 'App Restrictions',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              title: 'Support & About',
              items: [
                _SettingsItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help Center',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About TinyWiz',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: Text(
                  'Log Out',
                  style: GoogleFonts.outfit(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?img=47'), // Placeholder Avatar
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F0F13), width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Aastha Sharma',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'aastha.sharma@example.com',
          style: GoogleFonts.outfit(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Premium Member',
            style: GoogleFonts.outfit(
              color: const Color(0xFF6C63FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({required String title, required List<_SettingsItem> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C24),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final isLast = index == items.length - 1;
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: items[index].onTap,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(index == 0 ? 24 : 0),
                          bottom: Radius.circular(isLast ? 24 : 0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2B2B36),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  items[index].icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      items[index].title,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (items[index].subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        items[index].subtitle!,
                                        style: GoogleFonts.outfit(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withOpacity(0.05),
                        indent: 64,
                        endIndent: 16,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
