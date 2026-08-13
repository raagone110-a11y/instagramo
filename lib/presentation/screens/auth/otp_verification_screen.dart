import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ─── OTP Providers ────────────────────────────────────────────────────────────

final otpControllerProvider = StateProvider<String>((ref) => '');
final resendTimerProvider = StateProvider<int>((ref) => 60);
final isOtpLoadingProvider = StateProvider<bool>((ref) => false);
final targetEmailProvider = StateProvider<String>((ref) => 'user@example.com');

// ─── OTP Timer Provider ───────────────────────────────────────────────────────

final otpTimerProvider = StateNotifierProvider<OtpTimerNotifier, int>(
  (ref) => OtpTimerNotifier(),
);

class OtpTimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  OtpTimerNotifier() : super(60) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state = state - 1;
      } else {
        _timer?.cancel();
      }
    });
  }

  void resend() {
    state = 60;
    _timer?.cancel();
    _startTimer();
  }

  bool get canResend => state == 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ─── OTP Verification Screen ──────────────────────────────────────────────────

class OtpVerificationScreen extends ConsumerWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(otpTimerProvider);
    final isLoading = ref.watch(isOtpLoadingProvider);
    final targetEmail = ref.watch(targetEmailProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Back Button ──────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 22,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),

              const SizedBox(height: 24),

              // ── OTP Icon ─────────────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.mark_email_read_rounded,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
                  .animate()
                  .fade(duration: 600.ms)
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .align(alignment: Alignment.center),

              const SizedBox(height: 32),

              // ── Title ────────────────────────────────────────────────────────
              Text(
                'Verification Code',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              )
                  .animate()
                  .fade(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              // ── Subtitle ─────────────────────────────────────────────────────
              Text(
                'Enter the 6-digit code sent to',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              )
                  .animate()
                  .fade(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 8),

              Text(
                targetEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              )
                  .animate()
                  .fade(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 40),

              // ── OTP Input Field ──────────────────────────────────────────────
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  inactiveFillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  selectedFillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor:
                      Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  selectedColor: Theme.of(context).colorScheme.primary,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                autoFocus: true,
                enableActiveFill: true,
                onChanged: (value) {
                  ref.read(otpControllerProvider.notifier).state = value;
                },
                onCompleted: (value) {
                  ref.read(isOtpLoadingProvider.notifier).state = true;
                  // Simulate OTP verification
                  Future.delayed(const Duration(seconds: 1), () {
                    ref.read(isOtpLoadingProvider.notifier).state = false;
                    context.go('/home');
                  });
                },
              )
                  .animate()
                  .fade(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              // ── Error Message (if needed) ────────────────────────────────────
              // Animated error message can be shown here

              const SizedBox(height: 16),

              // ── Loading Indicator ────────────────────────────────────────────
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2.5,
                  ),
                ),

              const SizedBox(height: 24),

              // ── Resend Timer ─────────────────────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: timer > 0
                            ? "Didn't receive the code? "
                            : '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                      if (timer > 0)
                        TextSpan(
                          text: 'Resend in ${timer}s',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fade(delay: 600.ms, duration: 500.ms),

              const SizedBox(height: 20),

              // ── Resend Button ────────────────────────────────────────────────
              if (timer == 0)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(otpTimerProvider.notifier).resend();
                      // Trigger resend OTP logic
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Resend Code',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fade(duration: 400.ms)
                    .scale(duration: 400.ms),

              const Spacer(),

              // ── Auto-fill Hint ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your code is encrypted and secure',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
