import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    _textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinnedTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black,
        ),
      ),
    );
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 48,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              'Verification',
              style: GoogleFonts.openSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 48,
            ),
            Text('Please enter the 6-digit OTP sent to this 2902902902.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 16),
            SizedBox(
              height: 68,
              child: Pinput(
                  focusedPinTheme: defaultPinnedTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.purpleAccent,
                          ),
                          color: Colors.blue.withAlpha(20))),
                  length: 6,
                  controller: TextEditingController(),
                  focusNode: focusNode,
                  onCompleted: (pin) {
                    setState(() {
                      otpCode = pin;
                    });
                    //verify otp code
                  },
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.length == 6) {
                      // TODO: Call the verification API with the entered OTP
                      // and handle the success or failure response accordingly
                      // Example:
                      // verifyOtp(value);
                    }
                  },
                  defaultPinTheme: defaultPinnedTheme,
                  errorPinTheme: defaultPinnedTheme.copyWith(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red,
                          ),
                          color: Colors.red.withAlpha(128)))),
            ),
            const SizedBox(
              height: 32,
            ),
            const Text('Did not receive code?'),
            TextButton(
              onPressed: () {},
              child: Text(
                'Resend Code',
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
