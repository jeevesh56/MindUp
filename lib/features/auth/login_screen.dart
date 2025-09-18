import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../widgets/neuropulse_logo.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _showPassword = false;
  bool _isLoading = false;
  late AnimationController _bounceController;
  late AnimationController _glowController;
  
  // Bouncing animation state
  double _bounceX = 0.5;
  double _bounceY = 0.5;
  double _velocityX = 0.008; // Doubled again from 0.004
  double _velocityY = 0.004; // Doubled again from 0.002

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4), // Doubled again (8ms -> 4ms)
    )..repeat();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _bounceController.addListener(_updateBouncePosition);
  }

  void _updateBouncePosition() {
    setState(() {
      _bounceX += _velocityX;
      _bounceY += _velocityY;
      
      // Bounce off edges with more dynamic movement
      if (_bounceX <= 0 || _bounceX >= 0.9) {
        _velocityX = -_velocityX * (0.8 + (0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000));
        _bounceX = _bounceX <= 0 ? 0 : 0.9;
      }
      if (_bounceY <= 0 || _bounceY >= 0.8) {
        _velocityY = -_velocityY * (0.8 + (0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000));
        _bounceY = _bounceY <= 0 ? 0 : 0.8;
      }
      
      // Add some randomness to make it more organic
      if (DateTime.now().millisecondsSinceEpoch % 25 == 0) { // Even more frequent randomness
        _velocityX += (DateTime.now().millisecondsSinceEpoch % 3 - 1) * 0.0004; // Doubled again
        _velocityY += (DateTime.now().millisecondsSinceEpoch % 3 - 1) * 0.0004; // Doubled again
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.ensureSignedIn();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A0F2E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background effects
            _buildBackgroundEffects(),
            
            // Bouncing logo
            _buildBouncingLogo(),
            
            // Login form
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        // Glowing edges
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  const Color(0xFF7E57C2).withOpacity(0.2),
                  Colors.transparent,
                  const Color(0xFF7E57C2).withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),
        
        // Additional gradient overlays
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF7E57C2).withOpacity(0.1),
                  Colors.transparent,
                  const Color(0xFF7E57C2).withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
        
        // Diagonal gradient lines
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7E57C2).withOpacity(0.2),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF3F51B5).withOpacity(0.15),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),
        
        // Animated light streaks with enhanced effects
        ...List.generate(3, (index) {
          return Positioned(
            left: index == 0 ? MediaQuery.of(context).size.width * 0.25 :
                  index == 1 ? MediaQuery.of(context).size.width * 0.67 :
                  MediaQuery.of(context).size.width * 0.33,
            child: Container(
              width: 2,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFFB39DDB).withOpacity(0.5),
                    const Color(0xFF9C27B0).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB39DDB).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 2000.ms, delay: (index * 1000).ms)
                .fadeOut(duration: 2000.ms)
                .shimmer(duration: 3000.ms, delay: (index * 500).ms),
          );
        }),
      ],
    );
  }

  Widget _buildBouncingLogo() {
    return Positioned(
      left: _bounceX * MediaQuery.of(context).size.width,
      top: _bounceY * MediaQuery.of(context).size.height,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF9C27B0).withOpacity(0.6),
              const Color(0xFFB39DDB).withOpacity(0.4),
              const Color(0xFF3F51B5).withOpacity(0.3),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withOpacity(0.8),
              blurRadius: 40,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFFB39DDB).withOpacity(0.4),
              blurRadius: 60,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFF3F51B5).withOpacity(0.3),
              blurRadius: 80,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.5),
              ],
            ),
          ),
          child: const NeuroPulseLogo(
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C).withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF7E57C2).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo and title
                  _buildHeader(),
                  
                  const SizedBox(height: 32),
                  
                  // Email field
                  _buildEmailField(),
                  
                  const SizedBox(height: 24),
                  
                  // Password field
                  _buildPasswordField(),
                  
                  const SizedBox(height: 32),
                  
                  // Login button
                  _buildLoginButton(),
                  
                  const SizedBox(height: 16),
                  
                  // Sign up button
                  _buildSignUpButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  _buildDivider(),
                  
                  const SizedBox(height: 24),
                  
                  // Guest button
                  _buildGuestButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Privacy note
                  _buildPrivacyNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF9C27B0).withOpacity(0.2),
                const Color(0xFF3F51B5).withOpacity(0.2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9C27B0).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                  Colors.white.withOpacity(0.5),
                ],
              ),
            ),
            child: const NeuroPulseLogo(
              size: 64,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome Back!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Color(0xFF9C27B0),
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Where Technology Meets Tranquility',
          style: TextStyle(
            color: const Color(0xFF9E9E9E),
            fontSize: 14,
            shadows: [
              Shadow(
                color: const Color(0xFFB39DDB).withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
            prefixIcon: const Icon(Icons.mail, color: Color(0xFFB39DDB)),
            filled: true,
            fillColor: const Color(0xFF1C1C1C).withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF7E57C2).withOpacity(0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF7E57C2).withOpacity(0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF9C27B0),
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF9C27B0),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
            prefixIcon: const Icon(Icons.lock, color: Color(0xFFB39DDB)),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFFB39DDB),
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            filled: true,
            fillColor: const Color(0xFF1C1C1C).withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF7E57C2).withOpacity(0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF7E57C2).withOpacity(0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF9C27B0),
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF9C27B0),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7E57C2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB39DDB),
          side: const BorderSide(
            color: Color(0xFFB39DDB),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFB39DDB).withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFB39DDB).withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGuestLogin,
        icon: const Icon(Icons.person, size: 20),
        label: const Text('Continue as Guest'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB39DDB),
          side: BorderSide(
            color: const Color(0xFF3F51B5).withOpacity(0.3),
          ),
          backgroundColor: const Color(0xFF1C1C1C).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return const Text(
      '🔒 Your conversations are private and secure.',
      style: TextStyle(
        color: Color(0xFF9E9E9E),
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}
