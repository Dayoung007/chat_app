import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/utilities/assets_manager.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final TextEditingController _phoneNumberController = TextEditingController();

class _LoginScreenState extends State<LoginScreen> {
  Country selectedCountry = Country(
    phoneCode: '234',
    countryCode: 'NG',
    name: 'Nigeria',
    e164Sc: 0,
    level: 1,
    geographic: true,
    example: 'Nigeria',
    displayName: 'Nigeria',
    displayNameNoCountryCode: 'NG',
    e164Key: '',
  );



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _phoneNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final _authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Lottie.asset(AssetsManager.chatbubble),
              ),
              Text(
                'Flutter chat',
                style: GoogleFonts.openSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Add your phone number to get a verification code to verify',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    _phoneNumberController.text = value;
                  });
                },
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black38, width: 2),
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                            showPhoneCode: true,
                            countryListTheme: const CountryListThemeData(
                              bottomSheetHeight: 500,
                            ),
                            context: context,
                            onSelect: (Country value) {
                              setState(() {
                                selectedCountry = value;
                              });
                            });
                      },
                      child: Text(
                        '${selectedCountry.flagEmoji} ${selectedCountry.phoneCode}',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: _phoneNumberController.text.length > 9
                      ? _authProvider.isLoading
                          ? CircularProgressIndicator()
                          : InkWell(
                              onTap: () {
                                if (_phoneNumberController.text.length > 10) {
                                } else {
                                  final phoneNumber =
                                      '+${selectedCountry.phoneCode}${_phoneNumberController.text}';
                                  _authProvider.signInWithPhoneNumber(
                                      phoneNumber: phoneNumber, context: context);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: Icon(
                                  _phoneNumberController.text.length > 10
                                      ? Icons.cancel
                                      : Icons.check_circle_rounded,
                                  size: 35,
                                  color: _phoneNumberController.text.length > 10
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
