import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/service/device/biometric/biometric_service.dart';
import 'package:news_app/core/service/device/biometric/model/biometric.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app/feature/notification/domain/use_case/notification_websocket_user_case.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/core/service/logger_service.dart';
import 'package:packages/core/utils/validator.dart';
import 'package:packages/widget/animation/loading_widget/loading_widget.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/button_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/divider_widget/divider_widget.dart';
import 'package:packages/widget/layout/layout.dart';
import 'package:packages/widget/text_field_widget/text_field_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _apiUrlController = TextEditingController();

  final TextEditingController _webSocketUrlController = TextEditingController();

  Biometric? _biometricInfo;

  @override
  void initState() {
    _initializeBiometric();
    super.initState();
  }

  /// Initialize biometric service và lấy thông tin
  Future<void> _initializeBiometric() async {
    try {
      // Lấy thông tin biometric
      final biometricInfo = await BiometricService.I.biometric;

      if (mounted) {
        setState(() {
          _biometricInfo = biometricInfo;
        });
      }
    } catch (e) {
      printE('Error initializing biometric: $e');
    }
  }

  /// Hiển thị dialog để cập nhật URL
  void _showUrlConfigDialog() {
    _apiUrlController.text = AppConfigManagerBase.apiBaseUrl;
    _webSocketUrlController.text = AppConfigManagerBase.webSocketBaseUrl ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cập nhật Server URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldWidget(
                label: 'API Base URL',
                controller: _apiUrlController,
                borderRadius: BorderRadius.circular(4),
                focusNode: FocusNode(),
                primaryColor: AppThemeManager.primary,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập API URL';
                  }
                  if (!Uri.tryParse(value)!.hasAbsolutePath == true) {
                    return 'URL không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFieldWidget(
                label: 'WebSocket Base URL',
                controller: _webSocketUrlController,
                borderRadius: BorderRadius.circular(4),
                focusNode: FocusNode(),
                primaryColor: AppThemeManager.primary,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!Uri.tryParse(value)!.hasAbsolutePath == true) {
                      return 'URL không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
            TextButton(
              onPressed: () {
                if (_apiUrlController.text.isNotEmpty) {
                  try {
                    AppConfigManagerBase.updateApiBaseUrl(_apiUrlController.text.trim());
                    if (_webSocketUrlController.text.trim().isNotEmpty) {
                      AppConfigManagerBase.updateWebSocketBaseUrl(_webSocketUrlController.text.trim());
                      
                      // Cập nhật WebSocket service với URL mới
                      final notificationUseCase = getIt<NotificationWebsocketUseCase>();
                      notificationUseCase.updateWebSocketUrl(_webSocketUrlController.text.trim());
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật URL thành công!')));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật URL: $e')));
                  }
                }
              },
              child: Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthLoading) {
            LoadingWidget.loadingDialog(context);
          }
          if (state is AuthAuthenticated) {
            LoadingWidget.dismissLoading(context);
            AppNavigation.pushNamed(AppRouter.entryPoint);
          }
          if (state is AuthFailure) {
            LoadingWidget.dismissLoading(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));

          }
        },
        child: LayoutWidget(
          background: ColoredBox(color: AppThemeManager.background),
          appBar: AppBarWidget(
            boxShadow: BoxShadow(),
            backgroundColor: AppThemeManager.appBar,
            leading: IconButtonWidget(
              svgPath: $AssetsIconsFilledGen().backward,
              size: 24,
              color: AppThemeManager.icon,
              padding: EdgeInsets.all(12.0),
              onPressed: () => Navigator.pop(context),
            ),
            paddingTop: 0,
            paddingBottom: 16,
            title: Padding(
              padding: const EdgeInsets.only(left: 108, right: 108),
              child: SvgPicture.asset(
                $AssetsIconsBrandGen().titleBrand,
                height: 28,
                colorFilter: ColorFilter.mode(AppThemeManager.textPrimary, BlendMode.srcIn),
              ),
            ),
            actions: [
              IconButtonWidget(
                svgPath: $AssetsIconsFilledGen().setting,
                size: 24,
                color: AppThemeManager.icon,
                padding: EdgeInsets.all(12.0),
                onPressed: _showUrlConfigDialog,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36, vertical: 60),
                child: Form(
                  key: _globalKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        LocaleKeys.auth_login_log_in_or_create_account.tr,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${LocaleKeys.auth_login_by_continuing_you_agree.tr} ',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              TextSpan(
                                text: LocaleKeys.auth_login_terms_of_sale.tr,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        printE("Terms of sale Link");
                                      },
                              ),
                              TextSpan(text: " "),
                              TextSpan(
                                text: LocaleKeys.auth_login_terms_of_service.tr,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        printE("Terms of Service Link");
                                      },
                              ),
                              TextSpan(
                                text: " ${LocaleKeys.auth_login_and.tr} ",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              TextSpan(
                                text: LocaleKeys.auth_login_privacy_policy.tr,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        printE("Privacy Policy Link");
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFieldWidget(
                        label: LocaleKeys.auth_login_email_address.tr,
                        controller: _emailController,
                        borderRadius: BorderRadius.circular(4),
                        focusNode: FocusNode(),
                        primaryColor: AppThemeManager.primary,
                        showClearButton: true,
                        validator: (value) => Validator.validateEmail(value),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              LocaleKeys.auth_login_password.tr,
                              style: TextStyle(
                                color: AppThemeManager.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextFieldWidget(
                                  // label: LocaleKeys.auth_login_password.tr,
                                  controller: _passwordController,
                                  borderRadius: BorderRadius.circular(4),
                                  focusNode: FocusNode(),
                                  primaryColor: AppThemeManager.primary,
                                  svgSuffixIcon: $AssetsIconsFilledGen().eyeSlash,
                                  svgSuffixIconToggled: $AssetsIconsFilledGen().eye,
                                  obscureText: true,
                                  validator: (value) => Validator.validatePassword(value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      return GestureDetector(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 2),
                                          child: SvgPicture.asset(
                                            _biometricInfo?.hasFaceID == true
                                                ? $AssetsIconsFilledGen().faceid
                                                : $AssetsIconsFilledGen().touchid,
                                            height: 42,
                                            colorFilter: ColorFilter.mode(
                                              AppThemeManager.buttonPrimary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          // _handleBiometricAuthentication();
                                          context.read<AuthBloc>().add(
                                            AuthBiometricRequested(
                                              localizedReason: _biometricInfo?.typeName,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ButtonWidget(
                            backgroundColor: AppThemeManager.buttonPrimary,
                            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppThemeManager.buttonPrimaryText,
                              fontFamily: 'Roboto',
                            ),
                            borderRadius: 4,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            label: LocaleKeys.auth_login_continue_with_email.tr,
                            onPressed: () {
                              if (_globalKey.currentState?.validate() ?? false) {
                                context.read<AuthBloc>().add(
                                  AuthLoginRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: DividerWidget()),
                          Text(
                            " ${LocaleKeys.auth_login_or.tr} ",
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(fontFamily: 'Roboto'),
                          ),
                          Expanded(child: DividerWidget()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ButtonWidget(
                        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppThemeManager.buttonPrimary,
                          fontFamily: 'Roboto',
                        ),
                        widgetIcon: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SvgPicture.asset($AssetsIconsSocialGen().google),
                        ),
                        isOutlined: true,
                        borderRadius: 4,
                        border: BorderSide(color: AppThemeManager.buttonPrimary),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        label: LocaleKeys.auth_login_continue_with_google.tr,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      ButtonWidget(
                        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppThemeManager.buttonPrimary,
                          fontFamily: 'Roboto',
                        ),
                        widgetIcon: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SvgPicture.asset($AssetsIconsSocialGen().facebook),
                        ),
                        isOutlined: true,
                        borderRadius: 4,
                        border: BorderSide(color: AppThemeManager.buttonPrimary),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        label: LocaleKeys.auth_login_continue_with_facebook.tr,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      ButtonWidget(
                        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppThemeManager.buttonPrimary,
                          fontFamily: 'Roboto',
                        ),
                        widgetIcon: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SvgPicture.asset(
                            $AssetsIconsSocialGen().apple,
                            colorFilter: ColorFilter.mode(
                              AppThemeManager.buttonPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        isOutlined: true,
                        borderRadius: 4,
                        border: BorderSide(color: AppThemeManager.buttonPrimary),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        label: LocaleKeys.auth_login_continue_with_apple.tr,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
