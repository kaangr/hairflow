import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'dart:math' as math;

class LandingPage extends StatefulWidget {
  final VoidCallback onGoogleSignIn;
  final bool isLoading;

  const LandingPage({
    super.key,
    required this.onGoogleSignIn,
    this.isLoading = false,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _scaleIn = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Main Content
          SafeArea(
            child: isWide
                ? _buildWideLayout(context)
                : _buildNarrowLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D1F0E),
                const Color(0xFF1A3A1C),
                Color.lerp(
                  const Color(0xFF0D1F0E),
                  const Color(0xFF2E5A30),
                  (math.sin(_backgroundController.value * math.pi * 2) + 1) /
                      2,
                )!,
              ],
              stops: [
                0.0,
                0.5 +
                    0.1 *
                        math.sin(_backgroundController.value * math.pi * 2),
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: _ParticlesPainter(
              progress: _backgroundController.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Branding & Features
        Expanded(
          flex: 5,
          child: _buildBrandingSection(context),
        ),
        // Right side - Auth Card
        Expanded(
          flex: 4,
          child: Center(
            child: _buildAuthCard(context),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildLogo(),
            const SizedBox(height: 32),
            _buildTagline(context),
            const SizedBox(height: 48),
            _buildAuthCard(context),
            const SizedBox(height: 48),
            _buildFeaturesList(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 40),
              _buildTagline(context),
              const SizedBox(height: 56),
              _buildFeaturesList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleIn,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF2E7D32),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.grass,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF81C784),
                Color(0xFF4CAF50),
                Color(0xFF2E7D32),
              ],
            ).createShader(bounds),
            child: const Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saç Sağlığınızı\nKontrol Altına Alın',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 800 ? 48 : 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Kişiselleştirilmiş bakım rutinleri, akıllı hatırlatıcılar ve '
          'uzman tavsiyeleriyle saç dökülmesiyle mücadele edin.',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 800 ? 20 : 16,
            color: Colors.white.withOpacity(0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      (Icons.calendar_month_rounded, 'Günlük Rutin Takibi',
          'Hiçbir adımı atlamayın'),
      (Icons.notifications_active_rounded, 'Akıllı Hatırlatıcılar',
          'Zamanında bildirimler'),
      (Icons.school_rounded, 'Uzman Tavsiyeleri',
          'Kanıta dayalı bilgiler'),
      (Icons.insights_rounded, 'İlerleme Takibi',
          'Gelişiminizi görün'),
    ];

    return Column(
      children: features.map((feature) {
        return _FeatureItem(
          icon: feature.$1,
          title: feature.$2,
          subtitle: feature.$3,
        );
      }).toList(),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Container(
          width: MediaQuery.of(context).size.width > 800 ? 420 : double.infinity,
          margin: MediaQuery.of(context).size.width > 800
              ? const EdgeInsets.all(32)
              : EdgeInsets.zero,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.spa_rounded,
                size: 64,
                color: Color(0xFF81C784),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hoş Geldiniz',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Saç bakım yolculuğunuza başlamak için giriş yapın',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Google Sign In Button
              _GoogleSignInButton(
                onPressed: widget.onGoogleSignIn,
                isLoading: widget.isLoading,
              ),

              const SizedBox(height: 24),

              // Divider with text
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'veya',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Continue as Guest
              TextButton(
                onPressed: () {
                  // TODO: Continue as guest
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Misafir olarak devam et',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Terms text
              Text(
                'Giriş yaparak Kullanım Şartları ve '
                'Gizlilik Politikası\'nı kabul etmiş olursunuz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF81C784),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(_isHovered ? 0.3 : 0.1),
                    blurRadius: _isHovered ? 24 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Logo
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: CustomPaint(
                            painter: _GoogleLogoPainter(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Google ile Giriş Yap',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C4043),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.5,
      true,
      paint,
    );

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.0,
      1.0,
      true,
      paint,
    );

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.0,
      1.0,
      true,
      paint,
    );

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.0,
      0.5,
      true,
      paint,
    );

    // White center
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);

    // Blue bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - radius * 0.1,
        center.dy - radius * 0.3,
        radius * 0.9,
        radius * 0.6,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParticlesPainter extends CustomPainter {
  final double progress;

  _ParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw floating particles
    for (int i = 0; i < 30; i++) {
      final x = (i * 137.508 + progress * size.width) % size.width;
      final y = (i * 89.23 + progress * size.height * 0.5) % size.height;
      final opacity = 0.1 + 0.1 * math.sin(progress * math.pi * 2 + i);
      final radius = 2.0 + 3.0 * math.sin(i.toDouble());

      paint.color = const Color(0xFF4CAF50).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw gradient orbs
    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4CAF50).withOpacity(0.1),
          const Color(0xFF4CAF50).withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.8 +
                50 * math.sin(progress * math.pi * 2),
            size.height * 0.3 +
                30 * math.cos(progress * math.pi * 2),
          ),
          radius: 200,
        ),
      );
    canvas.drawCircle(
      Offset(
        size.width * 0.8 + 50 * math.sin(progress * math.pi * 2),
        size.height * 0.3 + 30 * math.cos(progress * math.pi * 2),
      ),
      200,
      orbPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

