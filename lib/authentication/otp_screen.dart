import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/utilities/global_method.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

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
    //get arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final authProvider = context.watch<AuthenticationProvider>();

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
            Text('Please enter the 6-digit OTP sent to this $phoneNumber.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 16),
            authProvider.isLoading
                ? const CircularProgressIndicator()
                : authProvider.isSuccessfulOtp == false
                    ?  SizedBox(
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
                  onCompleted: (pin) async {
                    setState(() {
                      otpCode = pin;
                    });


                    verifyOtpCode(
                      otpCode: otpCode!,
                      verificationId: verificationId,

                    );
                    await Future.delayed(Duration(seconds: 2));
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
            ) :


            CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 20,
                        child: Icon(Icons.check,
                        color: Colors.white,),
                      )
                    ,
            const SizedBox(
              height: 32,
            ),
          Text('Did not receive code?'),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                // Call the resendOtp method
                context.read<AuthenticationProvider>().resendOtp(
                  phoneNumber: phoneNumber,
                  context: context,
                );
              },
              child: Text('Resend OTP'),
            ),
          ]),
        ),
      ),
    );
  }

  void verifyOtpCode({
    required String otpCode,
    required String verificationId,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOtpCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: () async {
        bool userExists = await authProvider.isUserExists();
        if (userExists) {
          showSnackBar(context, "Fetching user data from Firestore");
          await authProvider.getUserDataFromFirestore();
          showSnackBar(context, "Saving user data to SharedPreferences");
          await authProvider.saveUserDataToSharedPreferences();
          await authProvider.checkInitialOtpState();
          await navigateToScreen(userExists: true);
        } else {
          await authProvider.checkInitialOtpState();
          await navigateToScreen(userExists: false);
        }
      },
    );
  }

  Future<void> navigateToScreen({required bool userExists}) async {
    try {
      userExists
          ? await Navigator.pushNamedAndRemoveUntil(
              context,
              Constants.homeScreen,
              (route) => false,
            )
          : await Navigator.pushNamedAndRemoveUntil(
              context,
              Constants.userInformationScreen,
              (route) => false,
            );
    } catch (e) {
      print("Navigation error: $e");
      // You might want to show an error dialog here
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Navigation Error"),
          content:
              const Text("An error occurred while trying to navigate. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}
