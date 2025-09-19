import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Conditional imports for WebView
import 'package:webview_flutter/webview_flutter.dart';

// Web helper with conditional imports
import 'smash_walls_web.dart' if (dart.library.html) 'smash_walls_web.dart' if (dart.library.io) 'smash_walls_web_stub.dart';

class SmashWallsScreen extends StatefulWidget {
  const SmashWallsScreen({super.key});

  @override
  State<SmashWallsScreen> createState() => _SmashWallsScreenState();
}

class _SmashWallsScreenState extends State<SmashWallsScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    if (kIsWeb) {
      // Web platform - initialize iframe
      SmashWallsWeb.initializeWebIframe();
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      // Android, iOS, macOS, Linux - use webview_flutter
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse('https://smashthewalls.com/'));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
          ).createShader(bounds),
          child: const Text(
            'Smash The Walls',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // WebView Content
          if (kIsWeb)
            _buildWebFallback()
          else if (_controller != null)
            WebViewWidget(controller: _controller!)
          else
            _buildFallback(),
          
          // Loading Indicator
          if (_isLoading)
            Container(
              color: const Color(0xFF121212),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E57C2)),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading Smash The Walls...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebFallback() {
    if (kIsWeb) {
      return SmashWallsWeb.buildWebIframe();
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF7E57C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF7E57C2),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E57C2).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.web,
                size: 80,
                color: Color(0xFF7E57C2),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Web version not available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              'Please use the desktop or mobile app',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFallback() {
    return const Center(
      child: Text(
        'WebView not supported on this platform',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}