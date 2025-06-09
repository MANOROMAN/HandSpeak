import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class UltraModernHelpPage extends StatefulWidget {
  const UltraModernHelpPage({Key? key}) : super(key: key);

  @override
  State<UltraModernHelpPage> createState() => _UltraModernHelpPageState();
}

class _UltraModernHelpPageState extends State<UltraModernHelpPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _faqController;
  late Animation<double> _headerAnimation;
  late Animation<double> _scaleAnimation;
  
  final List<int> _expandedItems = [];
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _faqController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _faqController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    _faqController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _faqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 280.h,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Animated Gradient
                  AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade800,
                              Colors.indigo.shade600,
                            ],
                            transform: GradientRotation(_headerAnimation.value * 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Floating Question Marks
                  ...List.generate(5, (index) {
                    return Positioned(
                      left: 50.0 + (index * 60),
                      top: 50.0 + math.sin(index) * 30,
                      child: AnimatedBuilder(
                        animation: _headerAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _headerAnimation.value * (index % 2 == 0 ? 1 : -1),
                            child: Opacity(
                              opacity: 0.2,
                              child: Icon(
                                Icons.help_outline,
                                size: (30 + index * 5).sp,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  
                  // Header Content
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: EdgeInsets.all(24.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.support_agent_rounded,
                                  size: 60.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            FadeTransition(
                              opacity: _headerAnimation,
                              child: Text(
                                T(context, 'profile.help'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Size nasıl yardımcı olabiliriz?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Help Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: Icons.video_library_rounded,
                          title: 'Video Rehberi',
                          subtitle: 'Kullanım videoları',
                          color: Colors.purple,
                          onTap: () {
                            // Navigate to video guides
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: Icons.chat_rounded,
                          title: 'Canlı Destek',
                          subtitle: '7/24 yardım',
                          color: Colors.green,
                          onTap: () {
                            _launchWhatsApp();
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // FAQ Section
                  _buildSectionTitle('Sıkça Sorulan Sorular'),
                  SizedBox(height: 16.h),
                  ..._buildFAQItems(context),
                  
                  SizedBox(height: 32.h),
                  
                  // Contact Section
                  _buildSectionTitle('İletişim'),
                  SizedBox(height: 16.h),
                  _buildContactSection(context),
                  
                  SizedBox(height: 32.h),
                  
                  // Support Team
                  _buildSectionTitle('Destek Ekibi'),
                  SizedBox(height: 16.h),
                  _buildSupportTeam(context),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.8),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 36.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
    );
  }
  
  List<Widget> _buildFAQItems(BuildContext context) {
    final faqs = [
      {
        'question': 'HandSpeak nasıl çalışır?',
        'answer': 'HandSpeak, yapay zeka destekli işaret dili çeviri uygulamasıdır. Kameranızı kullanarak işaret dili hareketlerinizi algılar ve metne çevirir. Ayrıca metni işaret diline çevirme özelliği de sunar.',
        'icon': Icons.psychology_rounded,
        'color': Colors.blue,
      },
      {
        'question': 'Uygulama hangi işaret dillerini destekliyor?',
        'answer': 'Şu anda Türk İşaret Dili (TİD) ve Amerikan İşaret Dili (ASL) desteklenmektedir. Diğer diller için çalışmalarımız devam etmektedir.',
        'icon': Icons.language_rounded,
        'color': Colors.green,
      },
      {
        'question': 'Video kayıtlarım nerede saklanıyor?',
        'answer': 'Video kayıtlarınız güvenli bulut sunucularımızda şifrelenerek saklanır. İstediğiniz zaman videolarınızı silebilir veya indirebilirsiniz.',
        'icon': Icons.cloud_rounded,
        'color': Colors.orange,
      },
      {
        'question': 'Çeviri doğruluğu nasıl artırılır?',
        'answer': 'İyi aydınlatılmış ortamda, kameranın karşısında net görünür şekilde işaret yapın. Ellerin ve parmakların net görünmesine dikkat edin.',
        'icon': Icons.tips_and_updates_rounded,
        'color': Colors.purple,
      },
      {
        'question': 'Uygulama internet olmadan çalışır mı?',
        'answer': 'Temel özellikler için internet bağlantısı gereklidir. Ancak indirdiğiniz eğitim videolarını çevrimdışı izleyebilirsiniz.',
        'icon': Icons.wifi_off_rounded,
        'color': Colors.red,
      },
    ];
    
    return faqs.asMap().entries.map((entry) {
      final index = entry.key;
      final faq = entry.value;
      final isExpanded = _expandedItems.contains(index);
      
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: (faq['color'] as Color).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedItems.remove(index);
                        } else {
                          _expandedItems.add(index);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: (faq['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  faq['icon'] as IconData,
                                  color: faq['color'] as Color,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  faq['question'] as String,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.expand_more_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: Text(
                                faq['answer'] as String,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
  
  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withOpacity(0.1),
            Colors.teal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.teal.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.contact_support_rounded,
            size: 48.sp,
            color: Colors.teal,
          ),
          SizedBox(height: 16.h),
          Text(
            'Bizimle İletişime Geçin',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Sorularınız için 7/24 buradayız',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24.h),
          _buildContactItem(
            icon: Icons.email_rounded,
            title: 'E-posta',
            subtitle: 'saricitarik@gmail.com',
            onTap: () => _launchEmail('saricitarik@gmail.com'),
          ),
          _buildContactItem(
            icon: Icons.email_rounded,
            title: 'Alternatif E-posta',
            subtitle: 'yusufgunel21@gmail.com',
            onTap: () => _launchEmail('yusufgunel21@gmail.com'),
          ),
          _buildContactItem(
            icon: Icons.phone_rounded,
            title: 'Telefon',
            subtitle: '+90 555 123 45 67',
            onTap: () => _launchPhone('+905551234567'),
          ),
          _buildContactItem(
            icon: Icons.chat_rounded,
            title: 'WhatsApp',
            subtitle: 'Hızlı destek için tıklayın',
            onTap: _launchWhatsApp,
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: Colors.teal,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSupportTeam(BuildContext context) {
    final team = [
      {
        'name': 'Tarık Sarıcı',
        'role': 'Kurucu & Geliştirici',
        'email': 'saricitarik@gmail.com',
        'avatar': Colors.blue,
      },
      {
        'name': 'Yusuf Günel',
        'role': 'Yazılım Geliştirici',
        'email': 'yusufgunel21@gmail.com',
        'avatar': Colors.green,
      },
    ];
    
    return Column(
      children: team.map((member) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (member['avatar'] as Color).withOpacity(0.8),
                      member['avatar'] as Color,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    member['name'].toString().split(' ').map((e) => e[0]).join(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      member['role'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: () => _launchEmail(member['email'] as String),
                      child: Text(
                        member['email'] as String,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=HandSpeak Destek',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
  
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
  
  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/905410657003?text=Merhaba, HandSpeak hakkında yardım almak istiyorum.');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }
}