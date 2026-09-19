import 'dart:convert';

import 'package:flutter/material.dart';
 
import '/services/auth_service.dart';
import '/services/token_service.dart';
import 'main_screen.dart';

import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_shadows.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import '/utils/responsive.dart';
import '/widgets/app_layout.dart';
 
/// ================================================================
/// LoginPage
/// Tela de autenticação (login/cadastro) do Mana Digital.
/// ================================================================
 
enum _AuthMode { login, register }
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  _AuthMode _mode = _AuthMode.login;
 
  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;
  bool _isLoading = false;
 
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
 
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
 
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
 
  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }
 
  Future<void> _submit() async {
    final formKey =
        _mode == _AuthMode.login
            ? _loginFormKey
            : _registerFormKey;

    if (formKey.currentState == null ||
        !formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_mode == _AuthMode.login) {
        // =========================================================
        // LOGIN
        // =========================================================

        final email = _loginEmailController.text.trim();
        final password = _loginPasswordController.text;

        final response = await ApiService.login(
          email,
          password,
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // JWT retornado pela API
          final token = data['token'];

          // Salva o JWT no armazenamento seguro
          await TokenService.saveToken(token);

          if (!mounted) return;

          // Vai para a Home e remove a tela de Login da pilha
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainScreen(),
            ),
          );
        } else {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ??
                    'E-mail ou senha inválidos.',
              ),
            ),
          );
        }
      } else {
        // =========================================================
        // CADASTRO
        // =========================================================

        final name = _regNameController.text.trim();
        final email = _regEmailController.text.trim();
        final password = _regPasswordController.text;

        final response = await ApiService.register(
          name,
          email,
          password,
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 ||
            response.statusCode == 201) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ??
                    'Cadastro realizado com sucesso!',
              ),
            ),
          );

          // Volta para o modo login
          setState(() {
            _mode = _AuthMode.login;
          });
        } else {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ??
                    'Erro ao realizar cadastro.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro de conexão com a API: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final maxContentWidth = Responsive.value(
      context: context,
      compact: double.infinity,
      normal: double.infinity,
      large: double.infinity,
      tablet: 480,
    );
 
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayout(
        scrollable: true,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.s6),
                _Header(),
                SizedBox(height: AppSpacing.s6),
                _XpBanner(),
                SizedBox(height: AppSpacing.s6),
                _TabSwitcher(
                  mode: _mode,
                  onChanged: (mode) => setState(() => _mode = mode),
                ),
                SizedBox(height: AppSpacing.s6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _mode == _AuthMode.login
                      ? _LoginForm(
                          key: const ValueKey('login'),
                          formKey: _loginFormKey,
                          emailController: _loginEmailController,
                          passwordController: _loginPasswordController,
                          obscurePassword: _obscureLoginPass,
                          onToggleObscure: () => setState(
                            () => _obscureLoginPass = !_obscureLoginPass,
                          ),
                          isLoading: _isLoading,
                          onSubmit: _submit,
                        )
                      : _RegisterForm(
                          key: const ValueKey('register'),
                          formKey: _registerFormKey,
                          nameController: _regNameController,
                          emailController: _regEmailController,
                          passwordController: _regPasswordController,
                          obscurePassword: _obscureRegPass,
                          onToggleObscure: () => setState(
                            () => _obscureRegPass = !_obscureRegPass,
                          ),
                          isLoading: _isLoading,
                          onSubmit: _submit,
                        ),
                ),
                SizedBox(height: AppSpacing.s8),
                _MetricBadges(),
                SizedBox(height: AppSpacing.s8),
                _Footer(),
                SizedBox(height: AppSpacing.s6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
/// ----------------------------------------------------------------
/// Cabeçalho: chip de protocolo + marca + descrição
/// ----------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chip "Logistics ESG • Governança Antirracista"
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s1,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, size: 14, color: AppColors.secondary),
              SizedBox(width: AppSpacing.s1_5),
              Flexible(
                child: Text(
                  'LOGISTICS ESG • GOVERNANÇA ANTIRRACISTA',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s3),
 
        // Marca
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.md,
              ),
              child: const Icon(Icons.hub, color: Colors.white),
            ),
            SizedBox(width: AppSpacing.s2),
            RichText(
              text: TextSpan(
                style: AppTextStyles.xxl,
                children: [
                  const TextSpan(text: 'Mana '),
                  TextSpan(
                    text: 'Digital',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s1),
 
        Text(
          'Qualificação corporativa em equidade racial, conformidade '
          'jurídica e liderança inclusiva.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
 
/// ----------------------------------------------------------------
/// Banner de XP / gamificação
/// ----------------------------------------------------------------
class _XpBanner extends StatelessWidget {
  const _XpBanner();
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.military_tech,
              size: 18,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protocolo de Integração',
                  style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Patent Status: Operador Nível 0',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s2,
              vertical: AppSpacing.s0_5,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                SizedBox(width: AppSpacing.s0_5),
                Text(
                  '+50 XP',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
/// ----------------------------------------------------------------
/// Alternador de aba Entrar / Cadastrar-se
/// ----------------------------------------------------------------
class _TabSwitcher extends StatelessWidget {
  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;
 
  const _TabSwitcher({required this.mode, required this.onChanged});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s0_5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Entrar',
              selected: mode == _AuthMode.login,
              onTap: () => onChanged(_AuthMode.login),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Cadastrar-se',
              selected: mode == _AuthMode.register,
              onTap: () => onChanged(_AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
 
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s2_5),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: selected ? AppShadows.sm : AppShadows.none,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
 
/// ----------------------------------------------------------------
/// Campo de texto padronizado (usa InputDecorationTheme do AppTheme,
/// mas reforça o ícone à esquerda / botão de visibilidade)
/// ----------------------------------------------------------------
class _AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
 
  const _AppTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: AppSpacing.s1),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.base,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
 
/// ----------------------------------------------------------------
/// Botão primário com gradiente (CTA)
/// ----------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;
 
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.lg,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s3_5),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s2),
                        Icon(icon, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
 
/// ----------------------------------------------------------------
/// Formulário de LOGIN
/// ----------------------------------------------------------------
class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onSubmit;
 
  const _LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSubmit,
  });
 
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AppTextField(
            label: 'E-mail Corporativo',
            hint: 'identificacao@empresa.com.br',
            icon: Icons.badge_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu e-mail';
              }
              if (!value.contains('@')) {
                return 'E-mail inválido';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.s3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SENHA DE ACESSO',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Esqueceu a senha?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s1),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: AppTextStyles.base,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe sua senha';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.s4),
          _PrimaryButton(
            label: 'Entrar na Missão',
            icon: Icons.arrow_forward,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          SizedBox(height: AppSpacing.s2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, size: 14, color: AppColors.secondary),
              SizedBox(width: AppSpacing.s1),
              Text(
                'Conexão Segura • Certificação ESG Corporativa',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
/// ----------------------------------------------------------------
/// Formulário de CADASTRO
/// ----------------------------------------------------------------
class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onSubmit;
 
  const _RegisterForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSubmit,
  });
 
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AppTextField(
            label: 'Nome Completo',
            hint: 'Nome e Sobrenome',
            icon: Icons.person_outline,
            controller: nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu nome';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.s3),
          _AppTextField(
            label: 'E-mail Corporativo',
            hint: 'colaborador@logistica.com.br',
            icon: Icons.domain_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu e-mail';
              }
              if (!value.contains('@')) {
                return 'E-mail inválido';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.s3),
          _AppTextField(
            label: 'Crie uma Senha Forte',
            hint: 'Mínimo 8 dígitos alfanuméricos',
            icon: Icons.key_outlined,
            controller: passwordController,
            obscureText: obscurePassword,
            suffix: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Mínimo de 8 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.s4),
          _PrimaryButton(
            label: 'Criar Credencial (+50 XP)',
            icon: Icons.how_to_reg,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
 
/// ----------------------------------------------------------------
/// Badges de métricas operacionais
/// ----------------------------------------------------------------
class _MetricBadges extends StatelessWidget {
  const _MetricBadges();
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricBadge(
            icon: Icons.verified_user_outlined,
            title: 'Módulos 2025',
            subtitle: 'Zero Complacência',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.s2),
        Expanded(
          child: _MetricBadge(
            icon: Icons.workspace_premium_outlined,
            title: 'Patente Ouro',
            subtitle: 'Trilha ESG Ativa',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
 
class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
 
  const _MetricBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s2_5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
/// ----------------------------------------------------------------
/// Rodapé de conformidade legal
/// ----------------------------------------------------------------
class _Footer extends StatelessWidget {
  const _Footer();
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: AppSpacing.s4),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.policy_outlined, size: 18, color: AppColors.secondary),
                  SizedBox(width: AppSpacing.s1),
                  Text(
                    'CONFORMIDADE LEGAL MANDATÁRIA',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s2),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.caption,
                  children: [
                    const TextSpan(
                      text: 'Plataforma em estrita conformidade com a ',
                    ),
                    TextSpan(
                      text: 'Lei 7.716/1989',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' (Crimes de Preconceito de Raça e Cor), '),
                    TextSpan(
                      text: 'Lei 14.532/2023',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text: ' (Equiparação da Injúria Racial ao Crime de Racismo) e o ',
                    ),
                    TextSpan(
                      text: 'Estatuto da Igualdade Racial',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' (Lei 12.288/2010).'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.s2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Privacidade LGPD', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                  SizedBox(width: AppSpacing.s2),
                  Text('•', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                  SizedBox(width: AppSpacing.s2),
                  Text('Canal de Denúncia 100% Anônimo', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
 