import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            // Menu items
            _menuSection('Hesap', [
              _menuItem(Icons.person_outline, 'Profil Bilgileri', () {}),
              _menuItem(Icons.lock_outline, 'Şifre Değiştir', () {}),
              _menuItem(Icons.notifications_outlined, 'Bildirim Ayarları', () {}),
            ]),
            const SizedBox(height: 16),

            _menuSection('Veri Yönetimi', [
              _menuItem(Icons.download_outlined, 'Verilerimi Dışa Aktar', () async {
                try {
                  final api = ref.read(apiClientProvider);
                  await api.get(ApiConstants.userExport);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verileriniz hazırlanıyor...')),
                    );
                  }
                } catch (_) {}
              }),
              _menuItem(Icons.privacy_tip_outlined, 'Gizlilik Politikası', () {
                context.push('/privacy-policy');
              }),
            ]),
            const SizedBox(height: 16),

            _menuSection('Uygulama', [
              _menuItem(Icons.info_outline, 'Hakkında', () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Diyabet Takip',
                  applicationVersion: '1.0.0',
                  children: [const Text('Diyabet hastalarının sağlık verilerini takip edebileceği AI destekli mobil uygulama.')],
                );
              }),
            ]),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Çıkış Yap'),
                      content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('İptal')),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Delete account
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hesabı Sil'),
                    content: const Text(
                      'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecektir.\n\n'
                      'Devam etmek istiyor musunuz?',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('İptal')),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Hesabı Sil', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    final api = ref.read(apiClientProvider);
                    await api.delete(ApiConstants.userDelete);
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('İşlem başarısız. Lütfen tekrar deneyin.')),
                      );
                    }
                  }
                }
              },
              child: const Text('Hesabımı Sil', style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
