import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hand_speak/core/utils/translation_helper.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Kastamonu Üniversitesi MMF coordinates
  static const LatLng _kastamonuUniversity = LatLng(41.3887, 33.7827);
  
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('university'),
      position: _kastamonuUniversity,
      infoWindow: InfoWindow(
        title: 'Kastamonu Üniversitesi',
        snippet: 'Mühendislik ve Mimarlık Fakültesi',
      ),
    ),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Enhanced Header Section with Animation
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                      Colors.blue.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Enhanced App Bar
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Hakkında',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(width: 48.w),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Animated App Logo and Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Hero(
                                tag: 'app_logo',
                                child: Container(
                                  width: 130.w,
                                  height: 130.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(65.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.sign_language,
                                    size: 65.sp,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'Hand Speak',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'İşaret Dili Çeviri Uygulaması',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Text(
                                  'Versiyon 1.0.0',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
              
              // Enhanced Content Section
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mission Section
                    _buildEnhancedSectionCard(
                      context,
                      icon: Icons.rocket_launch_outlined,
                      title: 'Misyonumuz',
                      content: 'Hand Speak, işitme engelli bireylerin günlük yaşamlarında karşılaştıkları iletişim engellerini ortadan kaldırmayı amaçlayan yenilikçi bir çeviri uygulamasıdır. Gelişmiş yapay zeka teknolojileri kullanarak işaret dili ile konuşma dili arasında anlık çeviri sağlayarak toplumsal entegrasyonu destekliyoruz.',
                      color: Colors.blue,
                      gradient: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Vision Section
                    _buildEnhancedSectionCard(
                      context,
                      icon: Icons.visibility_outlined,
                      title: 'Vizyonumuz',
                      content: 'Engelsiz bir dünya yaratmak için teknolojinin gücünü kullanarak işitme engelli bireylerin toplumsal hayata tam katılımını sağlamak. Her bireyin eşit iletişim hakkına sahip olduğu, kapsayıcı bir toplum inşa etmek vizyonumuzdur.',
                      color: Colors.green,
                      gradient: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Enhanced Features Section
                    _buildEnhancedSectionCard(
                      context,
                      icon: Icons.auto_awesome_outlined,
                      title: 'Özelliklerimiz',
                      content: '• Gerçek zamanlı işaret dili tanıma\n• Yapay zeka destekli çeviri\n• Çoklu dil desteği\n• Sesli geri bildirim\n• Öğrenme modülü\n• Kişiselleştirilebilir arayüz\n• Çevrimdışı kullanım desteği\n• Topluluk özelliği',
                      color: Colors.orange,
                      gradient: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Technology Section
                    _buildEnhancedSectionCard(
                      context,
                      icon: Icons.psychology_outlined,
                      title: 'Teknolojimiz',
                      content: 'Hand Speak, en son makine öğrenmesi algoritmaları, bilgisayar görüşü teknolojileri ve doğal dil işleme yöntemleri kullanılarak geliştirilmiştir. TensorFlow ve OpenCV gibi güçlü frameworkler ile desteklenen uygulamamız, %95 üzerinde doğruluk oranı sağlamaktadır.',
                      color: Colors.purple,
                      gradient: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Impact Section
                    _buildEnhancedSectionCard(
                      context,
                      icon: Icons.favorite_outline,
                      title: 'Sosyal Etkimiz',
                      content: 'Türkiye\'de yaklaşık 1.5 milyon işitme engelli bireyin yaşamını kolaylaştırmayı hedefliyoruz. Eğitim, iş hayatı ve sosyal ilişkilerde fırsat eşitliği sağlayarak toplumsal kalkınmaya katkıda bulunuyoruz.',
                      color: Colors.teal,
                      gradient: [Colors.teal.shade400, Colors.teal.shade600],
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Enhanced Location Section
                    _buildLocationSection(context, theme),
                    
                    SizedBox(height: 20.h),
                    
                    // Enhanced Help & Support Section
                    _buildHelpSupportSection(context, theme),
                    
                    SizedBox(height: 20.h),
                    
                    // Development Team Section
                    _buildDevelopmentTeamSection(context, theme),
                    
                    SizedBox(height: 20.h),
                    
                    // Enhanced Contact Section
                    _buildEnhancedContactSection(context, theme),
                    
                    SizedBox(height: 30.h),
                    
                    // Footer
                    _buildFooter(context, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSectionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location Header
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.location_on, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Geliştirme Merkezi',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        'Kastamonu Üniversitesi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Enhanced Google Maps
          Container(
            height: 220.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: Colors.red.shade200, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13.r),
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: const CameraPosition(
                  target: _kastamonuUniversity,
                  zoom: 15,
                ),
                markers: _markers,
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                myLocationButtonEnabled: false,
                buildingsEnabled: true,
                trafficEnabled: false,
                mapType: MapType.normal,
              ),
            ),
          ),
          
          // Enhanced Address
          Container(
            margin: EdgeInsets.all(20.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Kastamonu Üniversitesi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Mühendislik ve Mimarlık Fakültesi',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Kuzeykent Kampüsü, 37150 Kastamonu',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSupportSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.indigo.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.help_outline, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Yardım & Destek',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Hand Speak uygulamasını kullanırken herhangi bir sorun yaşıyor veya önerileriniz var mı? Bizimle iletişime geçmekten çekinmeyin. Kullanıcı deneyiminizi iyileştirmek için sürekli çalışıyoruz.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20.h),
            
            // Help Categories
            Row(
              children: [
                Expanded(
                  child: _buildHelpCategory(
                    icon: Icons.quiz,
                    title: 'SSS',
                    description: 'Sık sorulan sorular',
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildHelpCategory(
                    icon: Icons.video_library,
                    title: 'Rehberler',
                    description: 'Video eğitimler',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildHelpCategory(
                    icon: Icons.bug_report,
                    title: 'Hata Bildir',
                    description: 'Sorun bildirin',
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildHelpCategory(
                    icon: Icons.feedback,
                    title: 'Geri Bildirim',
                    description: 'Önerileriniz',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCategory({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentTeamSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.purple.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.group, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Geliştirici Ekibi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Hand Speak, Kastamonu Üniversitesi Mühendislik ve Mimarlık Fakültesi öğrencileri tarafından geliştirilmektedir. Proje, sosyal sorumluluk bilinciyle toplumsal fayda sağlamak amacıyla hayata geçirilmiştir.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20.h),
            
            // Team Members
            Row(
              children: [
                Expanded(
                  child: _buildTeamMember(
                    name: 'Tarık Sarıcı',
                    role: 'Proje Lideri & Geliştirici',
                    email: 'saricitarik@gmail.com',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTeamMember(
                    name: 'Yusuf Günel',
                    role: 'Yazılım Geliştirici',
                    email: 'yusufgunel21@gmail.com',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String email,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: color,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            role,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          InkWell(
            onTap: () => _launchEmail(email),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                email,
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedContactSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                ),
                borderRadius: BorderRadius.circular(50.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.contact_mail_outlined,
                size: 40.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'İletişim',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sorularınız, önerileriniz veya işbirliği teklifleriniz için bizimle iletişime geçin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            
            // Contact Methods
            _buildEnhancedContactItem(
              icon: Icons.email,
              title: 'E-posta',
              text: 'info@handspeak.com',
              onTap: () => _launchEmail('info@handspeak.com'),
              color: Colors.red,
            ),
            SizedBox(height: 12.h),
            _buildEnhancedContactItem(
              icon: Icons.web,
              title: 'Web Sitesi',
              text: 'www.handspeak.com',
              onTap: () => _launchUrl('https://www.handspeak.com'),
              color: Colors.blue,
            ),
            SizedBox(height: 12.h),
            _buildEnhancedContactItem(
              icon: Icons.phone,
              title: 'Telefon',
              text: '+90 (366) 280 12 00',
              onTap: () => _launchPhone('+903662801200'),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedContactItem({
    required IconData icon,
    required String title,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.sp, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          Text(
            '© 2025 Hand Speak',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Kastamonu Üniversitesi',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Herkes için erişilebilir iletişim',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.primaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Hand Speak İletişim',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
}