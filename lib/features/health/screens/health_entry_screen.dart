import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class HealthEntryScreen extends ConsumerStatefulWidget {
  const HealthEntryScreen({super.key});

  @override
  ConsumerState<HealthEntryScreen> createState() => _HealthEntryScreenState();
}

class _HealthEntryScreenState extends ConsumerState<HealthEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  final _weightController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();

  String _recordType = 'fasting';
  bool _isSubmitting = false;

  final _recordTypes = {
    'fasting': 'Açlık',
    'post_meal': 'Tokluk',
    'before_meal': 'Yemek Öncesi',
    'bedtime': 'Yatmadan Önce',
    'random': 'Rastgele',
  };

  @override
  void dispose() {
    _glucoseController.dispose();
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(apiClientProvider);
      final contextNote = _recordTypes[_recordType] ?? '';
      final userNote = _notesController.text.isNotEmpty ? ' - ${_notesController.text}' : '';
      final finalNote = '$contextNote$userNote'.trim();

      // 1. Glucose
      await api.post(ApiConstants.health, data: {
        'type': 'GLUCOSE',
        'value': double.parse(_glucoseController.text),
        'note': finalNote.isNotEmpty ? finalNote : null,
      });

      // 2. Weight
      if (_weightController.text.isNotEmpty) {
        await api.post(ApiConstants.health, data: {
          'type': 'WEIGHT',
          'value': double.parse(_weightController.text),
        });
      }

      // 3. Blood Pressure
      if (_systolicController.text.isNotEmpty && _diastolicController.text.isNotEmpty) {
        await api.post(ApiConstants.health, data: {
          'type': 'BLOOD_PRESSURE_SYSTOLIC',
          'value': double.parse(_systolicController.text),
        });
        await api.post(ApiConstants.health, data: {
          'type': 'BLOOD_PRESSURE_DIASTOLIC',
          'value': double.parse(_diastolicController.text),
        });
      }

      // 4. Heart Rate
      if (_heartRateController.text.isNotEmpty) {
        await api.post(ApiConstants.health, data: {
          'type': 'HEART_RATE',
          'value': double.parse(_heartRateController.text),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kayıtlar başarıyla eklendi ✓'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      _glucoseController.clear();
      _weightController.clear();
      _systolicController.clear();
      _diastolicController.clear();
      _heartRateController.clear();
      _notesController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kayıt eklenemedi. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sağlık Kaydı Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Record type
              const Text('Ölçüm Tipi', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recordTypes.entries.map((e) {
                  final selected = _recordType == e.key;
                  return ChoiceChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) => setState(() => _recordType = e.key),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Glucose (required)
              _buildInputCard(
                icon: Icons.bloodtype,
                color: AppColors.error,
                title: 'Kan Şekeri *',
                child: TextFormField(
                  controller: _glucoseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Örn: 120',
                    suffixText: 'mg/dL',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kan şekeri gerekli';
                    final num = double.tryParse(v);
                    if (num == null || num < 20 || num > 600) return '20-600 arası değer girin';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              _buildInputCard(
                icon: Icons.monitor_weight_outlined,
                color: AppColors.info,
                title: 'Kilo',
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Örn: 75', suffixText: 'kg'),
                ),
              ),
              const SizedBox(height: 16),

              // Blood pressure
              _buildInputCard(
                icon: Icons.favorite_outlined,
                color: AppColors.accent,
                title: 'Tansiyon',
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _systolicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Büyük'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('/', style: TextStyle(fontSize: 20)),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _diastolicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Küçük'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Heart rate
              _buildInputCard(
                icon: Icons.monitor_heart_outlined,
                color: AppColors.success,
                title: 'Nabız',
                child: TextFormField(
                  controller: _heartRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Örn: 72', suffixText: 'bpm'),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  hintText: 'Ek bilgi ekleyin...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: const Text('Kaydı Ekle'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
