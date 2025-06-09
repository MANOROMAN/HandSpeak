import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EnhancedWebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool isTranslatePage;
  
  const EnhancedWebViewScreen({
    Key? key,
    required this.title,
    required this.url,
    this.isTranslatePage = false,
  }) : super(key: key);

  @override
  State<EnhancedWebViewScreen> createState() => _EnhancedWebViewScreenState();
}

class _EnhancedWebViewScreenState extends State<EnhancedWebViewScreen> 
    with SingleTickerProviderStateMixin {
  late WebViewController _webViewController;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;
  
  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _initializeWebView();
  }
  
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            
            // Update navigation states
            _canGoBack = await _webViewController.canGoBack();
            _canGoForward = await _webViewController.canGoForward();
            setState(() {});
            
            // If translate page, inject JavaScript to focus on translate section
            if (widget.isTranslatePage) {
              _focusOnTranslateSection();
            }
            
            _animationController.forward();
          },
          onWebResourceError: (WebResourceError error) {
            _showErrorDialog(error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  
  void _focusOnTranslateSection() {
    // JavaScript to scroll to and highlight translate section
    const String js = '''
      // Find translate section by common identifiers
      var translateSection = document.querySelector('#translate') || 
                           document.querySelector('.translate') ||
                           document.querySelector('[data-translate]') ||
                           document.querySelector('iframe[src*="translate"]');
      
      if (translateSection) {
        // Scroll to translate section
        translateSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
        
        // Add highlight effect
        translateSection.style.border = '3px solid #2196F3';
        translateSection.style.borderRadius = '8px';
        translateSection.style.padding = '10px';
        translateSection.style.backgroundColor = 'rgba(33, 150, 243, 0.05)';
        
        // Remove highlight after 3 seconds
        setTimeout(() => {
          translateSection.style.border = '';
          translateSection.style.borderRadius = '';
          translateSection.style.padding = '';
          translateSection.style.backgroundColor = '';
        }, 3000);
      }
      
      // Hide unnecessary elements for better focus
      var elementsToHide = ['header', 'footer', '.ads', '.advertisement', '.sidebar'];
      elementsToHide.forEach(selector => {
        var elements = document.querySelectorAll(selector);
        elements.forEach(el => el.style.display = 'none');
      });
    ''';
    
    _webViewController.runJavaScript(js);
  }
  
  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse(_currentUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('URL açılamadı', isError: true);
    }
  }
  
  Future<void> _copyUrl() async {
    await Clipboard.setData(ClipboardData(text: _currentUrl));
    _showSnackBar('URL panoya kopyalandı');
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
  
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8.w),
            Text('Hata'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sayfa yüklenirken bir hata oluştu:'),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _webViewController.reload();
            },
            child: Text('Yeniden Dene'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: _isLoading ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentUrl.isNotEmpty)
                  Text(
                    _getDomainName(_currentUrl),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            actions: [
              if (widget.isTranslatePage)
                IconButton(
                  icon: const Icon(Icons.translate),
                  onPressed: _focusOnTranslateSection,
                  tooltip: 'Çeviri bölümüne git',
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _webViewController.reload(),
                tooltip: 'Yenile',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'copy':
                      _copyUrl();
                      break;
                    case 'open':
                      _openInBrowser();
                      break;
                    case 'desktop':
                      _webViewController.runJavaScript(
                        "document.querySelector('meta[name=\"viewport\"]').setAttribute('content', 'width=1024');"
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text('URL\'yi kopyala'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text('Tarayıcıda aç'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'desktop',
                    child: Row(
                      children: [
                        Icon(Icons.desktop_windows, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text('Masaüstü görünümü'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // WebView
          FadeTransition(
            opacity: _progressAnimation,
            child: WebViewWidget(controller: _webViewController),
          ),
          
          // Loading Progress Bar
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 3.h,
              ),
            ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        value: _loadingProgress > 0 ? _loadingProgress : null,
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Sayfa yükleniyor...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_loadingProgress > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '${(_loadingProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: _canGoBack ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  onPressed: _canGoBack
                    ? () => _webViewController.goBack()
                    : null,
                  tooltip: 'Geri',
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: _canGoForward ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  onPressed: _canGoForward
                    ? () => _webViewController.goForward()
                    : null,
                  tooltip: 'İleri',
                ),
                if (widget.isTranslatePage)
                  Container(
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: TextButton.icon(
                      onPressed: _focusOnTranslateSection,
                      icon: Icon(Icons.translate, color: Colors.white, size: 18.sp),
                      label: Text(
                        'Çeviri Alanı',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () => _webViewController.loadRequest(Uri.parse(widget.url)),
                  tooltip: 'Ana Sayfa',
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getDomainName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }
}