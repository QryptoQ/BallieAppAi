import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:yescoach/services/sentry.dart';
import '../models/ya_user.dart';
import './local_data.dart';
import './api_client.dart';

class AuthServices {
  static Future<bool> get isLoggedIn async {
    try {
      await LocalData.getAuthToken();
      return true;
    } on LocalDataException catch (e) {
      print(e);
      return false;
    } catch (e) {
      S.logError(e);

      throw e;
    }
  }

  static Future<YaUser> register({
    required String email,
    required String password,
  }) async {
    try {
      await ApiClient.post(
        'register',
        body: {
          'email': email,
          'password': password,
        },
        withToken: false,
      );
      var _user = await login(email: email, password: password);
      return _user;
    } on NetworkException catch (e) {
      S.logError(e);

      if (e.statusCode == 422) {
        // User Exists:
        throw AuthException(
          message: AppLocalizations.of(Get.context!)!
              .tm_error_registrationFailed_message_userExists,
          type: AuthExceptionType.userExists,
        );
      }

      // General Error:
      throw AuthException(
        message: AppLocalizations.of(Get.context!)!
            .tm_error_registrationFailed_message,
        type: AuthExceptionType.registerationFailed,
      );
    } catch (e) {
      S.logError(e);

      throw AuthException(
        message: AppLocalizations.of(Get.context!)!
            .tm_error_registrationFailed_message,
      );
    }
  }

  static Future<YaUser> login({
    required String email,
    required String password,
  }) async {
    try {
      var responseBody = await ApiClient.post(
        'login',
        body: {
          'email': email,
          'password': password,
        },
        withToken: false,
      );

      String _token = responseBody['token'];
      await LocalData.setAuthToken(_token);

      var _user = await getCurrentUser();
      return _user;
    } on NetworkException catch (e) {
      print('login error: $e');

      throw AuthException(
        type: AuthExceptionType.loginFailed,
        message: AppLocalizations.of(Get.context!)!
            .tm_error_loginFailed_userpass_message,
      );
    } catch (e) {
      S.logError(e);
      print('login error unknown: $e');

      throw AuthException(
        message: AppLocalizations.of(Get.context!)!
            .tm_error_loginFailed_userpass_message,
      );
    }
  }

  static Future<YaUser> getCurrentUser() async {
    try {
      var _userMap = await ApiClient.get('v1/me');
      return YaUser.fromMap(_userMap);
    } catch (e) {
      S.logError(e);
      print(e);

      throw AuthException(message: 'Catching user failed');
    }
  }

  static Future<void> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email']);

    final GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account != null) {
      final auth = await account.authentication;
      var responseBody = await ApiClient.post(
        'login/google',
        body: {'token': auth.accessToken},
        withToken: false,
      );

      String token = responseBody['token'];
      await LocalData.setAuthToken(token);
    }
  }

  static Future<void> loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

     if (result.status != LoginStatus.success || result.accessToken == null)
       throw AuthException(message: 'Facebook login failed.');

    if (result.status == LoginStatus.success && result.accessToken != null) {
      var responseBody = await ApiClient.post(
        'login/facebook',
        body: {'token': result.accessToken?.tokenString ?? ''},
        withToken: false,
      );

      String token = responseBody['token'];
      await LocalData.setAuthToken(token);
    }
  }

  static Future<void> loginWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (credential.givenName != null &&
        credential.familyName != null &&
        credential.email != null) {

      await _registerWithApple(
        email: credential.email ?? '',
        name: credential.givenName ?? '',
        lastname: credential.familyName ?? '',
        appleId: credential.userIdentifier ?? '',
      );
    }
      var responseBody = await ApiClient.post(
        'login/apple',
        body: {'apple_id': credential.userIdentifier},
        withToken: false,
      );

      String token = responseBody['token'];
      await LocalData.setAuthToken(token);

  }

  static Future<void> _registerWithApple({
    required String name,
    required String lastname,
    required String email,
    required String appleId,
  }) async {
    var responseBody = await ApiClient.post(
      'registerWithApple',
      body: {
        'name': name,
        'last_name': lastname,
        'email': email,
        'apple_id': appleId,
      },
      withToken: false,
    );

    print('register response: $responseBody');
  }

  static Future<void> requestForgetPasswordLink(String email) async {
    try {
      var res = await ApiClient.post(
        'requestresetpassword',
        body: {"email": email},
        withToken: false,
      );

      print('request reset pass: $res');
    } catch (e) {
      throw AuthException(
        message:
            AppLocalizations.of(Get.context!)!.tm_error_forgotPassword_message,
      );
    }
  }

  static Future<void> resetPassword({
    required String newPassword,
    required String resetToken,
  }) async {
    var res = await ApiClient.post(
      'resetpassword',
      body: {
        'token': resetToken,
        'password': newPassword,
      },
      withToken: false,
    );

    print('Reset password response: $res');
  }

  static Future<String> generateInviteMembers(String teamCode, String teamName, String? teamLogoUrl) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://links.ballie.app',
      link: Uri.parse('https://ballie.app/jointeam?code=$teamCode&name=$teamName'),
      androidParameters: AndroidParameters(
        packageName: 'com.shawoozy.yescoach',
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.shawoozy.yescoach',
        appStoreId: '1482824456'
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Join $teamName on Ballie!",
        description: 'The team code is $teamCode',
        imageUrl: Uri.parse(teamLogoUrl ?? 'https://ballie.app/wp-content/uploads/2021/08/Image-from-iOS-1.png')
      )
    );

    final ShortDynamicLink shortDynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortDynamicLink.shortUrl.toString();
  }

  static Future<void> verifyEmail(String token) async {
    try {
      await ApiClient.post(
        'verify',
        body: {'token': token},
        withToken: false,
      );
    } catch (e) {
      print('verifyEmail error: $e');
      S.logError('verifyEmail error: $e');

      throw AuthException(message: 'Email verify failed.');
    }
  }
}

enum AuthExceptionType {
  userExists,
  registerationFailed,
  loginFailed,
  userNotAuthorized,
}

class AuthException implements Exception {
  String? message;
  AuthExceptionType? type;
  AuthException({this.message, this.type});

  @override
  String toString() => 'Auth Error: $message';
}
