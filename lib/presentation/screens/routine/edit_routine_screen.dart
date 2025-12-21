import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_provider.dart';

/// Rutin düzenleme ekranı
class EditRoutineScreen extends StatefulWidget {
  final Routine routine;

  const EditRoutineScreen({
    super.key,
    required this.routine,
  });

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routine.name);
    _descriptionController = TextEditingController(text: widget.routine.description);
    _isActive = widget.routine.isActive;

    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final hasChanges = _nameController.text != widget.routine.name ||
        _descriptionController.text != widget.routine.description ||
        _isActive != widget.routine.isActive;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await _showDiscardDialog() ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rutini Düzenle'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'KAYDET',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Önizleme kartı
              _buildPreviewCard(),
              
              const SizedBox(height: 32),
              
              // Form alanları
              _buildFormSection(
                title: 'Rutin Bilgileri',
                icon: Icons.info_outline,
                children: [
                  // İsim
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Rutin Adı',
                      hintText: 'örn: Sabah Rutini',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Açıklama
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      hintText: 'Bu rutin hakkında kısa bir açıklama...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.description),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Durum
              _buildFormSection(
                title: 'Durum',
                icon: Icons.toggle_on,
                children: [
                  _buildStatusToggle(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Tehlikeli bölge
              _buildDangerZone(),
            ],
          ),
        ),
        
        // Alt buton
        bottomNavigationBar: _hasChanges
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Değişiklikleri Kaydet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.spa,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Önizleme',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Rutin Adı'
                          : _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isActive
                      ? Colors.green.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isActive ? 'Aktif' : 'Pasif',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_descriptionController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _descriptionController.text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rutin Aktif',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isActive
                      ? 'Bu rutin görevleri takvimde görünecek'
                      : 'Bu rutin geçici olarak devre dışı',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
                _onFieldChanged();
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: 20,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                'Tehlikeli Bölge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Bu rutini silmek, tüm ilişkili görevleri de kalıcı olarak silecektir.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Bu Rutini Sil',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutin adı boş olamaz'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<RoutineProvider>();
      final updatedRoutine = widget.routine.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );
      
      await provider.updateRoutine(updatedRoutine);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rutin güncellendi ✓'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Değişikliklerden Vazgeç?'),
        content: const Text(
          'Kaydedilmemiş değişiklikleriniz var. Çıkmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Vazgeç'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Rutini Sil'),
          ],
        ),
        content: Text(
          '"${widget.routine.name}" rutinini ve tüm görevlerini silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final provider = context.read<RoutineProvider>();
              await provider.deleteRoutine(widget.routine.id.toString());
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rutin silindi'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
                Navigator.pop(context); // RoutineDetailScreen'den de çık
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kalıcı Olarak Sil'),
          ),
        ],
      ),
    );
  }
}

