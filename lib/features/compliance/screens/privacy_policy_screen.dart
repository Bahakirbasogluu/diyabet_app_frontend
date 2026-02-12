import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik Politikası')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gizlilik Politikası',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Son güncelleme: Şubat 2026',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _section('1. Toplanan Veriler',
              'Uygulamamız aşağıdaki verileri toplamaktadır:\n\n'
              '• E-posta adresi ve ad-soyad bilgisi\n'
              '• Kan şekeri ölçüm değerleri\n'
              '• Kilo, tansiyon ve nabız bilgileri\n'
              '• Diyabet tipi ve ilaç bilgileri\n'
              '• Cihaz bilgileri ve push notification tokenleri',
            ),

            _section('2. Verilerin Kullanımı',
              'Topladığımız verileri şu amaçlarla kullanmaktayız:\n\n'
              '• Sağlık takibi ve analiz hizmeti sunmak\n'
              '• Kişiselleştirilmiş AI tavsiyeleri sağlamak\n'
              '• Hatırlatıcı bildirimler göndermek\n'
              '• Hizmet kalitesini artırmak',
            ),

            _section('3. Veri Güvenliği',
              'Verileriniz şifrelenerek güvenli sunucularda saklanmaktadır. '
              'End-to-end encryption ve JWT token tabanlı yetkilendirme kullanılmaktadır.',
            ),

            _section('4. Veri Silme Hakkı',
              'KVKK ve GDPR kapsamında verilerinizin silinmesini talep edebilirsiniz. '
              'Profil > Hesap Sil menüsünden tüm verilerinizi kalıcı olarak silebilirsiniz.',
            ),

            _section('5. Veri Dışa Aktarma',
              'Tüm kişisel verilerinizi JSON formatında dışa aktarabilirsiniz. '
              'Bu özelliğe Profil > Verilerimi Dışa Aktar menüsünden ulaşabilirsiniz.',
            ),

            _section('6. Üçüncü Taraf Paylaşımı',
              'Verileriniz hiçbir koşulda üçüncü taraflarla paylaşılmamaktadır. '
              'AI chatbot yanıtları uygulama içinde işlenmekte olup harici servislere veri aktarılmamaktadır.',
            ),

            _section('7. İletişim',
              'Gizlilik ile ilgili sorularınız için:\ndestek@diyabet-takip.com',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
