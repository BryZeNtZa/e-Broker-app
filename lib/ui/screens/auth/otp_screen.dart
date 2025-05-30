import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    required this.isDeleteAccount,
    required this.isEmailSelected,
    super.key,
    this.phoneNumber,
    this.email,
    this.password,
    this.otpVerificationId,
    this.countryCode,
    this.otpIs,
  });

  final bool isDeleteAccount;

  final bool isEmailSelected;
  final String? phoneNumber;
  final String? email;
  final String? password;
  final String? otpVerificationId;
  final String? countryCode;
  final String? otpIs;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SendOtpCubit()),
            BlocProvider(create: (context) => VerifyOtpCubit()),
          ],
          child: OtpScreen(
            isDeleteAccount: arguments['isDeleteAccount'] as bool? ?? false,
            phoneNumber: arguments['phoneNumber']?.toString() ?? '',
            email: arguments['email']?.toString() ?? '',
            otpVerificationId: arguments['otpVerificationId']?.toString() ?? '',
            countryCode: arguments['countryCode']?.toString() ?? '',
            otpIs: arguments['otpIs']?.toString() ?? '',
            isEmailSelected: arguments['isEmailSelected'] as bool? ?? false,
          ),
        );
      },
    );
  }
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? timer;
  ValueNotifier<int> otpResendTime = ValueNotifier<int>(
    Constant.otpResendSecond,
  );
  final TextEditingController phoneOtpController = TextEditingController();
  final TextEditingController emailOtpController = TextEditingController();
  int otpLength = 6;
  bool isOtpAutoFilled = false;
  final List<FocusNode> _focusNodes = [];
  int focusIndex = 0;
  String otpIs = '';

  @override
  void initState() {
    // otpResendTime = ValueNotifier<int>(
    //   widget.isEmailSelected
    //       ? Constant.otpResendSecondForEmail
    //       : Constant.otpResendSecond,
    // );
    otpIs = widget.otpIs ?? '';
    super.initState();
    if (timer != null) {
      timer!.cancel();
    }
    startTimer();
  }

  @override
  void dispose() {
    for (final fNode in _focusNodes) {
      fNode.dispose();
    }
    otpResendTime.dispose();
    phoneOtpController.dispose();
    emailOtpController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyOtpCubit, VerifyOtpState>(
      listener: (context, state) {
        if (state is VerifyOtpInProgress) {
          Widgets.showLoader(context);
        } else {
          Widgets.hideLoder(context);
        }
        if (state is VerifyOtpFailure) {
          Widgets.hideLoder(context);
          HelperUtils.showSnackBarMessage(
            context,
            state.errorMessage,
            type: MessageType.error,
          );
        }

        if (state is VerifyOtpSuccess) {
          Widgets.hideLoder(context);
          if (widget.isEmailSelected) {
            Navigator.of(context).pushReplacementNamed(
              Routes.login,
              arguments: {
                'isDeleteAccount': widget.isDeleteAccount,
              },
            );
            HelperUtils.showSnackBarMessage(
              context,
              'OTP verified successfully',
              type: MessageType.success,
            );
          }
          if (widget.isDeleteAccount) {
            context.read<DeleteAccountCubit>().deleteUserAccount(
                  context,
                );
          } else if (AppSettings.otpServiceProvider == 'firebase') {
            context.read<LoginCubit>().login(
                  type: LoginType.phone,
                  phoneNumber:
                      state.credential!.user!.phoneNumber?.toString() ?? '',
                  uniqueId: state.credential!.user!.uid?.toString() ?? '',
                  countryCode: widget.countryCode,
                );
          } else if (AppSettings.otpServiceProvider == 'twilio') {
            context.read<LoginCubit>().login(
                  type: LoginType.phone,
                  phoneNumber: widget.phoneNumber,
                  uniqueId: state.authId!,
                  countryCode: widget.countryCode,
                );
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          title: UiUtils.translate(context, 'enterCodeSend'),
          showBackButton: true,
        ),
        body: otpScreenContainer(context),
      ),
    );
  }

  Widget buildOtpContainer({
    required BuildContext context,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required List<TextInputFormatter> inputFormatters,
    required TextInputType keyboardType,
    required String buttonText,
    required dynamic Function(String) onCodeSubmitted,
    required dynamic Function(String) onCodeChanged,
    required Function() onPressed,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomText(
            UiUtils.translate(context, 'weSentCodeOnEmail'),
            fontSize: context.font.large,
            color: context.color.textColorDark.withValues(alpha: 0.8),
          ),
          CustomText(
            '${widget.isDeleteAccount ? HiveUtils.getUserDetails().email : widget.email}',
            fontSize: context.font.large,
            color: context.color.textColorDark.withValues(alpha: 0.8),
          ),
          SizedBox(
            height: 20.rh(context),
          ),
          PinFieldAutoFill(
            autoFocus: true,
            controller: emailOtpController,
            decoration: UnderlineDecoration(
              lineHeight: 1.5,
              colorBuilder: PinListenColorBuilder(
                context.color.tertiaryColor,
                Colors.grey,
              ),
            ),
            currentCode: demoOTP(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: Platform.isIOS
                ? const TextInputType.numberWithOptions(signed: true)
                : TextInputType.number,
            onCodeSubmitted: (code) {
              context.read<VerifyOtpCubit>().verifyEmailOTP(
                    otp: code,
                    email: widget.email ?? '',
                  );
            },
            onCodeChanged: (code) {
              if (code?.length == 6) {
                otpIs = code!;
                // setState(() {});
              }
            },
          ),

          // loginButton(context),
          if (!(timer?.isActive ?? false)) ...[
            SizedBox(
              height: 70,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IgnorePointer(
                  ignoring: timer?.isActive ?? false,
                  child: setTextbutton(
                    UiUtils.translate(context, 'resendCodeBtnLbl'),
                    (timer?.isActive ?? false)
                        ? Theme.of(context).colorScheme.textLightColor
                        : Theme.of(context).colorScheme.tertiaryColor,
                    FontWeight.bold,
                    resendOTP,
                    context,
                  ),
                ),
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(child: resendOtpTimerWidget()),
          ),

          loginButton(context),
        ],
      ),
    );
  }

  Widget otpScreenContainer(
    BuildContext context,
  ) =>
      widget.isEmailSelected
          ? Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomText(
                    UiUtils.translate(context, 'weSentCodeOnEmail'),
                    fontSize: context.font.large,
                    color: context.color.textColorDark.withValues(alpha: 0.8),
                  ),
                  CustomText(
                    '${widget.isDeleteAccount ? HiveUtils.getUserDetails().email : widget.email}',
                    fontSize: context.font.large,
                    color: context.color.textColorDark.withValues(alpha: 0.8),
                  ),
                  SizedBox(
                    height: 20.rh(context),
                  ),
                  PinFieldAutoFill(
                    autoFocus: true,
                    controller: emailOtpController,
                    decoration: UnderlineDecoration(
                      lineHeight: 1.5,
                      colorBuilder: PinListenColorBuilder(
                        context.color.tertiaryColor,
                        Colors.grey,
                      ),
                    ),
                    currentCode: demoOTP(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: Platform.isIOS
                        ? const TextInputType.numberWithOptions(signed: true)
                        : TextInputType.number,
                    onCodeSubmitted: (code) {
                      context.read<VerifyOtpCubit>().verifyEmailOTP(
                            otp: code,
                            email: widget.email ?? '',
                          );
                    },
                    onCodeChanged: (code) {
                      if (code?.length == 6) {
                        otpIs = code!;
                        // setState(() {});
                      }
                    },
                  ),

                  // loginButton(context),
                  if (!(timer?.isActive ?? false)) ...[
                    SizedBox(
                      height: 70,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IgnorePointer(
                          ignoring: timer?.isActive ?? false,
                          child: setTextbutton(
                            UiUtils.translate(context, 'resendCodeBtnLbl'),
                            (timer?.isActive ?? false)
                                ? Theme.of(context).colorScheme.textLightColor
                                : Theme.of(context).colorScheme.tertiaryColor,
                            FontWeight.bold,
                            resendOTP,
                            context,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(child: resendOtpTimerWidget()),
                  ),

                  loginButton(context),
                ],
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.isEmailSelected)
                    ...[]
                  else ...[
                    CustomText(
                      UiUtils.translate(context, 'weSentCodeOnNumber'),
                      fontSize: context.font.large,
                      color: context.color.textColorDark.withValues(alpha: 0.8),
                    ),
                    CustomText(
                      '+${widget.isDeleteAccount ? HiveUtils.getUserDetails().mobile : widget.countryCode}${widget.phoneNumber}',
                      fontSize: context.font.large,
                      color: context.color.textColorDark.withValues(alpha: 0.8),
                    ),
                  ],
                  SizedBox(
                    height: 20.rh(context),
                  ),
                  PinFieldAutoFill(
                    autoFocus: true,
                    controller: phoneOtpController,
                    decoration: UnderlineDecoration(
                      lineHeight: 1.5,
                      colorBuilder: PinListenColorBuilder(
                        context.color.tertiaryColor,
                        Colors.grey,
                      ),
                    ),
                    currentCode: demoOTP(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: Platform.isIOS
                        ? const TextInputType.numberWithOptions(signed: true)
                        : TextInputType.number,
                    onCodeSubmitted: (code) {
                      if (AppSettings.otpServiceProvider == 'firebase') {
                        if (widget.isDeleteAccount) {
                          context.read<VerifyOtpCubit>().verifyOTP(
                                verificationId: verificationID,
                                otp: code,
                              );
                        } else {
                          context.read<VerifyOtpCubit>().verifyOTP(
                                verificationId: widget.otpVerificationId,
                                otp: code,
                              );
                        }
                      } else if (AppSettings.otpServiceProvider == 'twilio') {
                        context.read<VerifyOtpCubit>().verifyOTP(
                              otp: widget.otpIs ?? '',
                              number:
                                  '+${widget.countryCode}${widget.phoneNumber}',
                            );
                      }
                    },
                    onCodeChanged: (code) {
                      if (code?.length == 6) {
                        otpIs = code!;
                        // setState(() {});
                      }
                    },
                  ),

                  // loginButton(context),
                  if (!(timer?.isActive ?? false)) ...[
                    SizedBox(
                      height: 70,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IgnorePointer(
                          ignoring: timer?.isActive ?? false,
                          child: setTextbutton(
                            UiUtils.translate(context, 'resendCodeBtnLbl'),
                            (timer?.isActive ?? false)
                                ? Theme.of(context).colorScheme.textLightColor
                                : Theme.of(context).colorScheme.tertiaryColor,
                            FontWeight.bold,
                            resendOTP,
                            context,
                          ),
                        ),
                      ),
                    ),
                  ],

                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(child: resendOtpTimerWidget()),
                  ),

                  loginButton(context),
                ],
              ),
            );
  Future<void> startTimer() async {
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (otpResendTime.value == 0) {
          timer.cancel();
          otpResendTime.value = Constant.otpResendSecond;
          setState(() {});
        } else {
          if (mounted) otpResendTime.value--;
        }
      },
    );
    setState(() {});
  }

  String demoOTP() {
    if (Constant.isDemoModeOn &&
        Constant.demoMobileNumber == widget.phoneNumber) {
      return Constant.demoModeOTP; // If true, return the demo mode OTP.
    } else {
      return ''; // If false, return an empty string.
    }
  }

  Widget resendOtpTimerWidget() {
    return ValueListenableBuilder(
      valueListenable: otpResendTime,
      builder: (context, value, child) {
        if (!(timer?.isActive ?? false)) {
          return const SizedBox.shrink();
        }
        String formatSecondsToMinutes(int seconds) {
          final minutes = seconds ~/ 60;
          final remainingSeconds = seconds % 60;
          return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
        }

        return SizedBox(
          height: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: "${UiUtils.translate(context, "resendMessage")} ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.textColorDark,
                  letterSpacing: 0.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: formatSecondsToMinutes(int.parse(value.toString())),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: UiUtils.translate(
                      context,
                      'resendMessageDuration',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
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

  void resendOTP() {
    if (widget.isEmailSelected) {
      context.read<SendOtpCubit>().resendEmailOTP(
            email: widget.email ?? '',
            password: widget.password ?? '',
          );
      return;
    }
    if (AppSettings.otpServiceProvider == 'firebase') {
      context.read<SendOtpCubit>().sendFirebaseOTP(
            phoneNumber: '+${widget.countryCode}${widget.phoneNumber}',
          );
    } else if (AppSettings.otpServiceProvider == 'twilio') {
      context.read<SendOtpCubit>().sendTwilioOTP(
            phoneNumber: '+${widget.countryCode}${widget.phoneNumber}',
          );
    }
  }

  Widget buildButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String buttonTitle,
    required bool disabled,
    double? height,
    double? width,
  }) {
    return MaterialButton(
      minWidth: width ?? 56.rw(context),
      height: height ?? 56.rh(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      color: context.color.tertiaryColor,
      disabledColor: context.color.textLightColor,
      onPressed: (disabled != true)
          ? () {
              HelperUtils.unfocus();
              onPressed.call();
            }
          : null,
      child: CustomText(
        buttonTitle,
        color: context.color.buttonColor,
        fontSize: context.font.larger,
      ),
    );
  }

  Widget loginButton(BuildContext context) {
    return buildButton(
      context,
      onPressed: onTapLogin,
      disabled: false,
      width: MediaQuery.of(context).size.width,
      buttonTitle: UiUtils.translate(
        context,
        'comfirmBtnLbl',
      ),
    );
  }

  Future<void> onTapLogin() async {
    if (widget.isEmailSelected) {
      try {
        await context.read<VerifyOtpCubit>().verifyEmailOTP(
              otp: emailOtpController.text,
              email: widget.email ?? '',
            );
        if (context.read<VerifyOtpCubit>().state is VerifyOtpSuccess) {
          await Navigator.pushReplacementNamed(
            context,
            Routes.main,
            arguments: {
              'from': 'login',
            },
          );
        }
        return;
      } catch (e) {
        await HelperUtils.showSnackBarMessage(
          context,
          e.toString(),
          messageDuration: 1,
        );
        return;
      }
    }
    try {
      if (phoneOtpController.text.isEmpty) {
        await HelperUtils.showSnackBarMessage(
          context,
          UiUtils.translate(context, 'lblEnterOtp'),
          messageDuration: 2,
        );
        return;
      }
      if (AppSettings.otpServiceProvider == 'firebase') {
        if (widget.isDeleteAccount) {
          await context.read<VerifyOtpCubit>().verifyOTP(
                verificationId: verificationID,
                otp: phoneOtpController.text,
              );
        } else {
          await context.read<VerifyOtpCubit>().verifyOTP(
                verificationId: widget.otpVerificationId,
                otp: phoneOtpController.text,
              );
        }
      } else if (AppSettings.otpServiceProvider == 'twilio') {
        await context.read<VerifyOtpCubit>().verifyOTP(
              otp: phoneOtpController.text,
              number: '+${widget.countryCode}${widget.phoneNumber}',
            );
      }
    } catch (e) {
      Widgets.hideLoder(context);
      await HelperUtils.showSnackBarMessage(
        context,
        'invalidOtp'.translate(context),
      );
    }
  }
}
