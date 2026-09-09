import 'package:flutter/material.dart';

// Responsive Breakpoints
class ResponsiveBreakpoints {
  static const mobileMax = 599.0;
  static const tabletMin = 600.0;
  static const tabletMax = 1199.0;
  static const desktopMin = 1200.0;

  static bool isMobile(double width) => width < tabletMin;
  static bool isTablet(double width) => width >= tabletMin && width < desktopMin;
  static bool isDesktop(double width) => width >= desktopMin;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State Variables
  bool isLoginMode = true; // true = Login, false = Register
  bool showLoginPassword = false;
  bool showRegisterPassword = false;
  bool isLoading = false;

  // Form Controllers
  late TextEditingController loginEmailController;
  late TextEditingController loginPasswordController;
  late TextEditingController registerNameController;
  late TextEditingController registerEmailController;
  late TextEditingController registerPasswordController;

  @override
  void initState() {
    super.initState();
    loginEmailController = TextEditingController();
    loginPasswordController = TextEditingController();
    registerNameController = TextEditingController();
    registerEmailController = TextEditingController();
    registerPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    super.dispose();
  }

  void _handleAuthSubmit() {
    setState(() => isLoading = true);

    // Simula delay de autenticação
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => isLoading = false);
        // Aqui você pode navegar para HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLoginMode ? 'Acesso Autorizado!' : 'Credencial Criada!'),
            backgroundColor: const Color(0xFF4338ca),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 Get Device Size and Orientation
    final size = MediaQuery.of(context).size;
    final isTablet = ResponsiveBreakpoints.isTablet(size.width);
    final isDesktop = ResponsiveBreakpoints.isDesktop(size.width);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // 📐 Calculate Dynamic Sizes based on device
    final horizontalPadding = isDesktop ? 64.0 : isTablet ? 32.0 : 16.0;
    final verticalSpacing = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;
    final logoSize = isDesktop ? 56.0 : isTablet ? 48.0 : 40.0;
    final headerFontSize = isDesktop ? 28.0 : isTablet ? 24.0 : 20.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    final labelFontSize = isDesktop ? 12.0 : isTablet ? 11.0 : 10.0;
    final buttonHeight = isDesktop ? 56.0 : 48.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0b1326),
      body: isLandscape && !isDesktop
          ? _buildLandscapeLayout(
              size,
              horizontalPadding,
              verticalSpacing,
              logoSize,
              headerFontSize,
              subtitleFontSize,
            )
          : _buildPortraitLayout(
              size,
              isTablet,
              isDesktop,
              horizontalPadding,
              verticalSpacing,
              logoSize,
              headerFontSize,
              subtitleFontSize,
              labelFontSize,
              buttonHeight,
            ),
    );
  }

  // 📱 PORTRAIT LAYOUT (Mobile, Tablet, Desktop)
  Widget _buildPortraitLayout(
    Size size,
    bool isTablet,
    bool isDesktop,
    double horizontalPadding,
    double verticalSpacing,
    double logoSize,
    double headerFontSize,
    double subtitleFontSize,
    double labelFontSize,
    double buttonHeight,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Ambient Glow & Header Section
          Stack(
            children: [
              // Decorative glows
              Positioned(
                top: -48,
                left: size.width / 2 - 128,
                child: Container(
                  width: 256,
                  height: 128,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4338ca).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                top: -16,
                right: 24,
                child: Container(
                  width: 128,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03b5d3).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 24),
                child: Column(
                  children: [
                    // Corporate Protocol Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222a3d),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield, color: Color(0xFF4cd7f6), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'LOGISTICS ESG • GOVERNANÇA ANTIRRACISTA',
                            style: TextStyle(
                              color: const Color(0xFF4cd7f6),
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Hanken Grotesk',
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 0.5),
                    // Mana Digital Brand Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4338ca), Color(0xFF4cd7f6)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4338ca).withOpacity(0.3),
                                blurRadius: 12,
                              )
                            ],
                          ),
                          child: Icon(Icons.hub, color: Colors.white, size: logoSize * 0.5),
                        ),
                        const SizedBox(width: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Mana ',
                                style: TextStyle(
                                  color: const Color(0xFFdae2fd),
                                  fontSize: headerFontSize,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Sora',
                                  letterSpacing: -0.02,
                                ),
                              ),
                              TextSpan(
                                text: 'Digital',
                                style: TextStyle(
                                  color: const Color(0xFF4cd7f6),
                                  fontSize: headerFontSize,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Sora',
                                  letterSpacing: -0.02,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing * 0.5),
                    // Subtitle
                    SizedBox(
                      width: isDesktop ? 500 : double.infinity,
                      child: Text(
                        'Qualificação corporativa em equidade racial,\nconformidade jurídica e liderança inclusiva.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFfc7c4d7),
                          fontSize: subtitleFontSize,
                          fontFamily: 'Hanken Grotesk',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing),
          // Gamified XP Reward Pill
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              width: isDesktop ? 500 : double.infinity,
              child: Container(
                padding: EdgeInsets.all(horizontalPadding * 0.75),
                decoration: BoxDecoration(
                  color: const Color(0xFF131b2e),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF171f33),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.military_tech, color: Color(0xFF4cd7f6), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Protocolo de Integração',
                              style: TextStyle(
                                color: const Color(0xFFdae2fd),
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Sora',
                              ),
                            ),
                            Text(
                              'Patent Status: Operador Nível 0',
                              style: TextStyle(
                                color: const Color(0xFfc7c4d7),
                                fontSize: labelFontSize,
                                fontFamily: 'Hanken Grotesk',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4cd7f6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, color: Color(0xFF4cd7f6), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '+50 XP',
                            style: TextStyle(
                              color: const Color(0xFF4cd7f6),
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing),
          // Tab Switcher
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              width: isDesktop ? 500 : double.infinity,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF060e20),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginMode = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.4),
                          decoration: BoxDecoration(
                            color: isLoginMode ? const Color(0xFF222a3d) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isLoginMode
                                ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
                                : [],
                          ),
                          child: Text(
                            'Entrar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isLoginMode ? const Color(0xFFdae2fd) : const Color(0xFfc7c4d7),
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginMode = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.4),
                          decoration: BoxDecoration(
                            color: !isLoginMode ? const Color(0xFF222a3d) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !isLoginMode
                                ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
                                : [],
                          ),
                          child: Text(
                            'Cadastrar-se',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !isLoginMode ? const Color(0xFFdae2fd) : const Color(0xFfc7c4d7),
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing),
          // Form Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              width: isDesktop ? 500 : double.infinity,
              child: isLoginMode
                  ? _buildLoginForm(labelFontSize, subtitleFontSize, buttonHeight)
                  : _buildRegisterForm(labelFontSize, subtitleFontSize, buttonHeight),
            ),
          ),
          SizedBox(height: verticalSpacing),
          // Operational Metric Badges
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              width: isDesktop ? 500 : double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(horizontalPadding * 0.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060e20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF171f33),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.verified_user, color: Color(0xFF4338ca), size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Módulos 2025',
                                  style: TextStyle(
                                    color: const Color(0xFFdae2fd),
                                    fontSize: labelFontSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Hanken Grotesk',
                                  ),
                                ),
                                Text(
                                  'Zero Complacência',
                                  style: TextStyle(
                                    color: const Color(0xFfc7c4d7),
                                    fontSize: labelFontSize - 2,
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(horizontalPadding * 0.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060e20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF171f33),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.workspace_premium, color: Color(0xFF4cd7f6), size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patente Ouro',
                                  style: TextStyle(
                                    color: const Color(0xFFdae2fd),
                                    fontSize: labelFontSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Hanken Grotesk',
                                  ),
                                ),
                                Text(
                                  'Trilha ESG Ativa',
                                  style: TextStyle(
                                    color: const Color(0xFfc7c4d7),
                                    fontSize: labelFontSize - 2,
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: verticalSpacing),
          // Footer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              width: isDesktop ? 500 : double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.policy, color: Color(0xFF4cd7f6), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'CONFORMIDADE LEGAL MANDATÓRIA',
                        style: TextStyle(
                          color: const Color(0xFFdae2fd),
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Hanken Grotesk',
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'Plataforma em estrita conformidade com a Lei 7.716/1989 (Crimes de Preconceito de Raça e Cor), Lei 14.532/2023 (Equiparação da Injúria Racial ao Crime de Racismo) e o Estatuto da Igualdade Racial (Lei 12.288/2010).',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFfc7c4d7),
                      fontSize: labelFontSize - 1,
                      fontFamily: 'Hanken Grotesk',
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Privacidade LGPD',
                        style: TextStyle(
                          color: const Color(0xFF918fa0),
                          fontSize: labelFontSize - 1,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                      SizedBox(width: verticalSpacing * 0.25),
                      Text(
                        '•',
                        style: TextStyle(
                          color: const Color(0xFF918fa0),
                          fontSize: labelFontSize - 1,
                        ),
                      ),
                      SizedBox(width: verticalSpacing * 0.25),
                      Text(
                        'Canal de Denúncia 100% Anônimo',
                        style: TextStyle(
                          color: const Color(0xFF918fa0),
                          fontSize: labelFontSize - 1,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 1.5),
        ],
      ),
    );
  }

  // 🌄 LANDSCAPE LAYOUT (Tablet/Mobile em landscape)
  Widget _buildLandscapeLayout(
    Size size,
    double horizontalPadding,
    double verticalSpacing,
    double logoSize,
    double headerFontSize,
    double subtitleFontSize,
  ) {
    return Row(
      children: [
        // Left Side - Branding
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFF060e20),
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4338ca), Color(0xFF4cd7f6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.hub, color: Colors.white, size: logoSize * 0.5),
                ),
                SizedBox(height: verticalSpacing),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mana ',
                        style: TextStyle(
                          color: const Color(0xFFdae2fd),
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Sora',
                        ),
                      ),
                      TextSpan(
                        text: 'Digital',
                        style: TextStyle(
                          color: const Color(0xFF4cd7f6),
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                Text(
                  'Equidade Racial\nConformidade Jurídica\nLiderança Inclusiva',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFfc7c4d7),
                    fontSize: subtitleFontSize,
                    fontFamily: 'Hanken Grotesk',
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Side - Forms
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                children: [
                  // Tab Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131b2e),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isLoginMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isLoginMode ? const Color(0xFF222a3d) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Entrar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isLoginMode ? const Color(0xFFdae2fd) : const Color(0xFfc7c4d7),
                                  fontSize: subtitleFontSize - 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isLoginMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !isLoginMode ? const Color(0xFF222a3d) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Cadastrar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isLoginMode ? const Color(0xFFdae2fd) : const Color(0xFfc7c4d7),
                                  fontSize: subtitleFontSize - 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  // Form
                  isLoginMode
                      ? _buildLoginForm(subtitleFontSize - 2, subtitleFontSize - 1, 44)
                      : _buildRegisterForm(subtitleFontSize - 2, subtitleFontSize - 1, 44),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🔐 LOGIN FORM BUILDER
  Widget _buildLoginForm(double labelFontSize, double subtitleFontSize, double buttonHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL CORPORATIVO',
          style: TextStyle(
            color: const Color(0xFfc7c4d7),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'Hanken Grotesk',
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: loginEmailController,
          style: TextStyle(
            color: const Color(0xFFdae2fd),
            fontSize: subtitleFontSize,
            fontFamily: 'Hanken Grotesk',
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail, color: Color(0xFF918fa0), size: 18),
            hintText: 'seu.email@empresa.com',
            hintStyle: const TextStyle(color: Color(0xFF918fa0)),
            filled: true,
            fillColor: const Color(0xFF171f33),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SENHA',
          style: TextStyle(
            color: const Color(0xFfc7c4d7),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'Hanken Grotesk',
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: loginPasswordController,
          obscureText: !showLoginPassword,
          style: TextStyle(
            color: const Color(0xFFdae2fd),
            fontSize: subtitleFontSize,
            fontFamily: 'Hanken Grotesk',
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.key, color: Color(0xFF918fa0), size: 18),
            hintText: 'Mínimo 8 dígitos',
            hintStyle: const TextStyle(color: Color(0xFF918fa0)),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => showLoginPassword = !showLoginPassword),
              child: Icon(
                showLoginPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF918fa0),
                size: 18,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF171f33),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleAuthSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338ca),
              disabledBackgroundColor: const Color(0xFF2d3449),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF4cd7f6),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Acessar Plataforma',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sora',
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // 📝 REGISTER FORM BUILDER
  Widget _buildRegisterForm(double labelFontSize, double subtitleFontSize, double buttonHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOME COMPLETO',
          style: TextStyle(
            color: const Color(0xFfc7c4d7),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'Hanken Grotesk',
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: registerNameController,
          style: TextStyle(
            color: const Color(0xFFdae2fd),
            fontSize: subtitleFontSize,
            fontFamily: 'Hanken Grotesk',
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person, color: Color(0xFF918fa0), size: 18),
            hintText: 'Seu nome completo',
            hintStyle: const TextStyle(color: Color(0xFF918fa0)),
            filled: true,
            fillColor: const Color(0xFF171f33),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'EMAIL CORPORATIVO',
          style: TextStyle(
            color: const Color(0xFfc7c4d7),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'Hanken Grotesk',
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: registerEmailController,
          style: TextStyle(
            color: const Color(0xFFdae2fd),
            fontSize: subtitleFontSize,
            fontFamily: 'Hanken Grotesk',
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail, color: Color(0xFF918fa0), size: 18),
            hintText: 'seu.email@empresa.com',
            hintStyle: const TextStyle(color: Color(0xFF918fa0)),
            filled: true,
            fillColor: const Color(0xFF171f33),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SENHA',
          style: TextStyle(
            color: const Color(0xFfc7c4d7),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'Hanken Grotesk',
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: registerPasswordController,
          obscureText: !showRegisterPassword,
          style: TextStyle(
            color: const Color(0xFFdae2fd),
            fontSize: subtitleFontSize,
            fontFamily: 'Hanken Grotesk',
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.key, color: Color(0xFF918fa0), size: 18),
            hintText: 'Mínimo 8 dígitos alfanuméricos',
            hintStyle: const TextStyle(color: Color(0xFF918fa0)),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => showRegisterPassword = !showRegisterPassword),
              child: Icon(
                showRegisterPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF918fa0),
                size: 18,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF171f33),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleAuthSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338ca),
              disabledBackgroundColor: const Color(0xFF2d3449),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF4cd7f6),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Criar Credencial',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sora',
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
