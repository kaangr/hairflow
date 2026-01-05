import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

/// Debug Screen - Kullanıcı bilgilerini göster (Admin yapabilmek için)
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String? _userId;
  String? _email;
  String? _displayName;
  String? _role;
  int? _roleId;
  bool? _isAdmin;
  bool? _isExpert;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authService = context.read<AuthService>();
    
    setState(() => _isLoading = true);
    
    try {
      final user = authService.currentUser;
      final role = await authService.getUserRole();
      final roleId = await authService.getUserRoleId();
      final isAdmin = await authService.isAdmin();
      final isExpert = await authService.isExpert();

      setState(() {
        _userId = user?.uid;
        _email = user?.email;
        _displayName = user?.displayName;
        _role = role;
        _roleId = roleId;
        _isAdmin = isAdmin;
        _isExpert = isExpert;
        _isLoading = false;
      });

      // Console'a da yazdır
      print('═══════════════════════════════════════════');
      print('🔐 KULLANICI BİLGİLERİ');
      print('═══════════════════════════════════════════');
      print('User ID (UID):  $_userId');
      print('Email:          $_email');
      print('Display Name:   $_displayName');
      print('Role:           $_role');
      print('Role ID:        $_roleId');
      print('Is Admin:       $isAdmin');
      print('Is Expert:      $isExpert');
      print('═══════════════════════════════════════════');
      print('');
      print('📝 Firebase Console\'da Admin yapmak için:');
      print('1. https://console.firebase.google.com');
      print('2. Firestore Database → Data');
      print('3. users → $_userId');
      print('4. Edit document');
      print('5. Ekle: role = "admin", roleId = 1');
      print('═══════════════════════════════════════════');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Hata: $e');
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopyalandı: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Debug - Kullanıcı Bilgileri'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, 
                          color: Colors.deepPurple, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bu ekranda giriş yapmış kullanıcının bilgilerini görebilirsiniz. Admin yapmak için User ID\'yi kullanın.',
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // User ID (En önemli!)
                  _buildInfoCard(
                    title: '🆔 User ID (UID)',
                    value: _userId ?? 'Yok',
                    isImportant: true,
                    onCopy: () => _copyToClipboard(_userId ?? '', 'User ID'),
                  ),

                  const SizedBox(height: 12),

                  // Email
                  _buildInfoCard(
                    title: '📧 Email',
                    value: _email ?? 'Yok',
                    onCopy: () => _copyToClipboard(_email ?? '', 'Email'),
                  ),

                  const SizedBox(height: 12),

                  // Display Name
                  _buildInfoCard(
                    title: '👤 Display Name',
                    value: _displayName ?? 'Yok',
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Rol Bilgileri
                  Text(
                    '🎭 Rol Bilgileri',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: 'Role (String)',
                    value: _role ?? 'Yok',
                    color: _getRoleColor(_role),
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: 'Role ID (Number)',
                    value: _roleId?.toString() ?? 'Yok',
                    color: _getRoleColor(_role),
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: 'Is Admin?',
                    value: _isAdmin == true ? '✅ Evet' : '❌ Hayır',
                    color: _isAdmin == true ? Colors.green : Colors.grey,
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    title: 'Is Expert?',
                    value: _isExpert == true ? '✅ Evet' : '❌ Hayır',
                    color: _isExpert == true ? Colors.orange : Colors.grey,
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, 
                              color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Admin Yapmak İçin:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStep('1', 'Firebase Console\'a git'),
                        _buildStep('2', 'Firestore Database → Data'),
                        _buildStep('3', 'users → $_userId'),
                        _buildStep('4', 'Edit document (kalem ikonu)'),
                        _buildStep('5', 'Ekle: role = "admin"'),
                        _buildStep('6', 'Ekle: roleId = 1'),
                        _buildStep('7', 'Update butonuna bas'),
                        _buildStep('8', 'Uygulamayı yeniden başlat'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Refresh Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadUserInfo,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Bilgileri Yenile'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Console Link
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Firebase Console URL'sini kopyala
                        const url = 'https://console.firebase.google.com';
                        _copyToClipboard(url, 'Firebase Console URL');
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Firebase Console URL\'yi Kopyala'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    bool isImportant = false,
    Color? color,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isImportant 
            ? Colors.amber.shade50 
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImportant 
              ? Colors.amber.shade300 
              : Colors.grey.shade300,
          width: isImportant ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 20),
              tooltip: 'Kopyala',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'expert':
        return Colors.orange;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

