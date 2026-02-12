import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _healthDataConsent = false;
  bool _analyticsConsent = false;
  bool _notificationConsent = false;

  bool get _canProceed => _healthDataConsent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.privacy_tip, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Veri İzinleri',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Uygulamayı kullanmak için aşağıdaki izinleri onaylamanız gerekmektedir.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Expanded(
                child: ListView(
                  children: [
                    _buildConsentTile(
                      title: 'Sağlık Verisi İşleme',
                      subtitle: 'Kan şekeri ve sağlık verilerinizin işlenmesine izin veriyorum.',
                      required: true,
                      value: _healthDataConsent,
                      onChanged: (v) => setState(() => _healthDataConsent = v!),
                    ),
                    const SizedBox(height: 12),
                    _buildConsentTile(
                      title: 'Analiz ve İstatistik',
                      subtitle: 'Verilerimin anonim olarak analiz edilmesine izin veriyorum.',
                      required: false,
                      value: _analyticsConsent,
                      onChanged: (v) => setState(() => _analyticsConsent = v!),
                    ),
                    const SizedBox(height: 12),
                    _buildConsentTile(
                      title: 'Bildirimler',
                      subtitle: 'Hatırlatıcı ve uyarı bildirimleri almak istiyorum.',
                      required: false,
                      value: _notificationConsent,
                      onChanged: (v) => setState(() => _notificationConsent = v!),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.push('/privacy-policy'),
                      child: const Text('Gizlilik Politikasını Oku'),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _canProceed ? () => context.go('/dashboard') : null,
                  child: const Text('Devam Et'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentTile({
    required String title,
    required String subtitle,
    required bool required,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    if (required) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Zorunlu', style: TextStyle(fontSize: 10, color: AppColors.error)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
