import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_color.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/routes/app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.firebaseUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            title: const Text('Akun Saya', style: TextStyle(color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 3),
                          boxShadow: [
                            BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 15),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.accent.withOpacity(0.2),
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person, color: Colors.white, size: 44)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? 'Pelanggan DavPhone',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '-',
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Content ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Akun Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 40),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pelanggan Setia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Terima kasih telah mempercayai DavPhone!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistik Ringkas
                  Row(
                    children: [
                      _buildStatItem(context, '0', 'Pesanan\nAktif', Icons.pending_actions_outlined),
                      _buildStatItem(context, '0', 'Riwayat\nPesanan', Icons.receipt_long_outlined),
                      _buildStatItem(context, '7', 'Hari\nGaransi', Icons.shield_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu Utama
                  const Text('Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, [
                    _MenuItem(
                      Icons.receipt_long_outlined, 'Riwayat Pesanan',
                      'Lihat semua pesanan Anda', AppColors.info,
                      () => Navigator.pushNamed(context, AppRouter.orders),
                    ),
                    _MenuItem(
                      Icons.shopping_cart_outlined, 'Keranjang Servis',
                      'Layanan yang menunggu dipesan', AppColors.accent,
                      () => Navigator.pushNamed(context, AppRouter.cart),
                    ),
                    _MenuItem(
                      Icons.local_offer_outlined, 'Promo & Diskon',
                      'Penawaran spesial untuk Anda', AppColors.success,
                      () {},
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Pengaturan
                  const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, [
                    _MenuItem(
                      Icons.dark_mode_outlined, 'Tampilan Gelap',
                      theme.isDark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
                      AppColors.primary,
                      null,
                      trailing: Switch(
                        value: theme.isDark,
                        onChanged: (_) => context.read<ThemeProvider>().toggle(),
                        activeColor: AppColors.accent,
                      ),
                    ),
                    _MenuItem(
                      Icons.notifications_outlined, 'Notifikasi',
                      'Aktifkan pengingat pesanan', AppColors.warning,
                      () {},
                    ),
                    _MenuItem(
                      Icons.help_outline, 'Bantuan & FAQ',
                      'Pertanyaan yang sering ditanyakan', AppColors.info,
                      () {},
                    ),
                    _MenuItem(
                      Icons.info_outline, 'Tentang Aplikasi',
                      'DavPhone Service v1.0.0', Colors.grey,
                      () => _showAboutDialog(context),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, auth),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'DavPhone Service © 2024 • v1.0.0',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 24),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
                trailing: item.trailing ?? (item.onTap != null ? const Icon(Icons.chevron_right) : null),
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (i < items.length - 1)
                Divider(height: 1, color: Theme.of(context).dividerColor, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?'),
        content: const Text('Anda akan keluar dari DavPhone Service. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (r) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DavPhone Service',
      applicationVersion: 'v1.0.0',
      applicationLegalese: '© 2024 DavPhone Service. All rights reserved.',
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  _MenuItem(this.icon, this.title, this.subtitle, this.iconColor, this.onTap, {this.trailing});
}
