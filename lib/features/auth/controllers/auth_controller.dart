import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:yescoach/controllers/app_controller.dart';
import 'package:yescoach/controllers/chat_controller.dart';
import 'package:yescoach/helpers/methods.dart';
import 'package:yescoach/models/ya_notification.dart';
import 'package:yescoach/services/authentication.dart';
import 'package:yescoach/services/database.dart';
import 'package:yescoach/services/local_data.dart';
import 'package:yescoach/services/sentry.dart';
import 'package:yescoach/widgets/screens/email_verified_screen.dart';
import 'package:yescoach/widgets/screens/register_screen.dart';
import 'package:yescoach/widgets/screens/reset_password.dart';
import 'package:yescoach/widgets/screens/root_screen.dart';
import 'package:yescoach/widgets/screens/team_select.dart';
import 'package:yescoach/widgets/toast_message.dart';

enum AuthState {
  loading,
  login,
  register,
  loggedIn,
}

class AuthController extends GetxController {
  Rx<AuthState> _authState = AuthState.login.obs;
  String? resetToken;
  String? inviteTeamCode;
  String? inviteTeamName;

  AuthState get authState => _authState.value;
  set authState(AuthState authState) => _authState.value = authState;

  late bool isLoggedIn;

  @override
  void onInit() async {
    await Firebase.initializeApp();

    try {
      isLoggedIn = await AuthServices.isLoggedIn;
      if (isLoggedIn) {
        await initFirebaseDynamicLinks(onboarding: false);
        authState = AuthState.loggedIn;
        Get.offAndToNamed(RootScreen.route);
      } else {
        await initFirebaseDynamicLinks(onboarding: false);
        authState = AuthState.login;
      }
    } catch (e) {
      await initFirebaseDynamicLinks(onboarding: false);
      authState = AuthState.login;
    }

    super.onInit();
  }

  void toggleAuthState({required AuthState state}) {
    authState = state;
  }

  void showTerms() async {
    await Methods.launchUrlC("https://ballie.app/privacy/");
  }

  void showPrivacy() async {
    await Methods.launchUrlC("https://ballie.app/privacy/");
  }

  Future createUser({
    required String email,
    required String password,
  }) async {
    // authState = AuthState.loading;
    Get.dialog(
      Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      barrierColor: Colors.black26,
      useSafeArea: false,
      barrierDismissible: false,
    );
    try {
      await AuthServices.register(
        email: email,
        password: password,
      );
      Get.close(1);
      Get.offAndToNamed(RootScreen.route);
    } on AuthException catch (e) {
      Get.close(1);
      ToastMessage.error(
        title: AppLocalizations.of(Get.context!)!
            .tm_error_registrationFailed_title,
        message: e.message!,
      );
      S.logError(e);
    } catch (e) {
      Get.close(1);
      ToastMessage.error(
        title: AppLocalizations.of(Get.context!)!
            .tm_error_registrationFailed_title,
        message: AppLocalizations.of(Get.context!)!
            .tm_error_registrationFailed_message,
      );
      S.logError(e);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    Get.dialog(
      Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      barrierColor: Colors.black26,
      useSafeArea: false,
      barrierDismissible: false,
    );

    try {
      await AuthServices.login(
        email: email,
        password: password,
      );
      log("Saad");
      log("Saad");

      await initFirebaseDynamicLinks();
      log("S22241q324");

      Get.offAndToNamed(RootScreen.route);
      isLoggedIn = true;
    } on AuthException catch (e) {
      Get.close(1);
      ToastMessage.error(
        title: AppLocalizations.of(Get.context!)!.tm_error_loginFailed_title,
        message: e.message!,
      );
      S.logError(e);
    } catch (e) {
      Get.close(1);
      ToastMessage.error(
        title: AppLocalizations.of(Get.context!)!.tm_error_loginFailed_title,
        message: AppLocalizations.of(Get.context!)!.tm_error_unexpected,
      );
      S.logError(e);
    }
  }

  Future<void> loginWithGoogle() async {
    Get.dialog(
      Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      barrierColor: Colors.black26,
      useSafeArea: false,
      barrierDismissible: false,
    );
    try {
      await AuthServices.loginWithGoogle();
      Get.close(1);
      authState = AuthState.loggedIn;
      await initFirebaseDynamicLinks();
      Get.offAndToNamed(RootScreen.route);
      isLoggedIn = true;
    } catch (e) {
      print(e);
      Get.close(1);
      ToastMessage.error(
        title: AppLocalizations.of(Get.context!)!.tm_error_loginFailed_title,
        message: AppLocalizations.of(Get.context!)!.tm_error_unexpected,
      );
      S.logError(e);
    }
  }

  Future<void> loginWithFacebook() async {
    Get.dialog(
      Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      barrierColor: Colors.black26,
      useSafeArea: false,
      barrierDismissible: false,
    );

    isLoggedIn = true;
    try {
      await AuthServices.loginWithFacebook();
      Get.close(1);
      authState = AuthState.loggedIn;
      await initFirebaseDynamicLinks();
      Get.offAndToNamed(RootScreen.route);
    } catch (e) {
      Get.close(1);
      ToastMessage.error(
        title: AppLocalizations.of(Get.context!)!.tm_error_loginFailed_title,
        message: AppLocalizations.of(Get.context!)!.tm_error_unexpected,
      );
      S.logError(e);
    }
  }

  Future<void> requestVerifyEmail(String email) async {
    await DatabaseServices.requestEmailVerification(email);
  }

  Future<void> loginWithApple() async {
    Get.dialog(
      Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      barrierColor: Colors.black26,
      useSafeArea: false,
      barrierDismissible: false,
    );

    isLoggedIn = true;
    try {
      await AuthServices.loginWithApple();
      Get.close(1);
      authState = AuthState.loggedIn;
      await initFirebaseDynamicLinks();
      Get.offAndToNamed(RootScreen.route);
      isLoggedIn = true;
    } catch (e) {
      Get.close(1);
      ToastMessage.error(
        title: AppLocalizations.of(Get.context!)!.tm_error_loginFailed_title,
        message: AppLocalizations.of(Get.context!)!.tm_error_unexpected,
      );
      S.logError(e);
    }
  }

  Future<void> logout() async {
    await LocalData.clearData();

    Get.offNamed(RegisterScreen.route);
    authState = AuthState.login;

    Get.delete<AppController>();
    isLoggedIn = false;
  }

  Future<void> deleteAccount() async {
    await DatabaseServices.deleteAccount();
    await logout();
  }

  Future<void> requestResetLink(String email) async {
    await AuthServices.requestForgetPasswordLink(email);
  }

  Future<void> resetPassword(String password) async {
    if (resetToken != null) {
      try {
        await AuthServices.resetPassword(
            newPassword: password, resetToken: resetToken!);
      } catch (e) {
        ToastMessage.error(
          title:
              AppLocalizations.of(Get.context!)!.tm_error_resetPassword_title,
          message: AppLocalizations.of(Get.context!)!.tm_error_unexpected,
        );
        S.logError(e);
      }
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await AuthServices.verifyEmail(token);
    } catch (e) {
      print('verify email failed: $e');
    }
  }

  Future<void> initFirebaseDynamicLinks(
      {bool onboarding = true, bool skipTeams = false}) async {
    log("Saad111");
    // AppLinks().uriLinkStream.listen((uri) {
    //   debugPrint('onAppLink: $uri');
    // });
    AppLinks().uriLinkStream.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData, onboarding, skipTeams);
      log("Saad222");
    }).onError((error) {
      // Handle errors
    });

    final Uri? initialLink = await AppLinks().getInitialLink();

    // final PendingDynamicLinkData? initialLink =
    //     await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      _handleDynamicLink(initialLink, onboarding, skipTeams);
    }

    final Uri? initialData = await AppLinks().getInitialLink();
    final Uri? initialDeepLink = initialData;

    if (initialDeepLink != null) {
      S.logError('initialDeepLink is not null');
      _handleDynamicLink(initialDeepLink, onboarding, skipTeams);
    }
  }

  Future<void> _handleDynamicLink(
      Uri link, bool onboarding, bool skipTeams) async {
    var path = link.path;
    var origin = link.origin;

    print('_handleDynamicLink ...');
    print('path: $path');
    print('origin: $origin');

    if (path == '/verifyemail') {
      print('Verify email dynamic link received');
      var token = link.queryParameters['token'];
      if (token != null) {
        verifyEmail(token).then((_) {
          Get.to(() => EmailVerifiedScreen());
        }).onError((error, stackTrace) {
          ToastMessage.error(
            title: AppLocalizations.of(Get.context!)!.tm_error_general_title,
            message:
                AppLocalizations.of(Get.context!)!.tm_error_general_message,
          );
        });
      } else {
        print('link is broken (token is null)');
      }
    } else if (path == '/resetpassword') {
      // Reset password dynamic link received:
      print('Reset password dynamic link received');

      resetToken = link.queryParameters['token'];

      if (resetToken != null) {
        Get.to(() => ResetPassword());
      }
    } else if (path == '/jointeam') {
      // Invite members dynamic link:
      var teamCode = link.queryParameters['code'];
      var teamName = link.queryParameters['name'];
      if (teamCode != null) {
        inviteTeamCode = teamCode;
        inviteTeamName = teamName;
        print('invitee team code: $inviteTeamCode');
        if (!skipTeams) {
          try {
            var currentTeams = await DatabaseServices.getTeams();

            await DatabaseServices.joinTeam(inviteTeamCode!);

            if (onboarding)
              Get.find<AppController>()
                ..yaTeamList = await DatabaseServices.getTeams();
            else
              Get.find<AppController>()..refreshTeams();

            Get.toNamed(
              UserTeamSelect.route,
              arguments: {
                'message': 'Team joined!',
                "onboarded": currentTeams.isEmpty
              },
            );
          } on DatabaseException catch (e) {
            ToastMessage.error(
                title: "Something went wrong", message: e.message!);
          }
        }
      }
    }
  }

  Future<void> _initNotifications() async {
    try {
      print('Initializing notifications ...');
      var notificationSettings =
          await FirebaseMessaging.instance.requestPermission();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        // Update the iOS foreground notification presentation options to allow
        // heads up notifications.
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: false,
        );

        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        var firebaseMessaging = FirebaseMessaging.instance;
        // Application opened from terminated state:
        var initialMessage = await firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          handleFCMMessages(initialMessage);
        }

        // Application opened from terminated state:
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) {
          if (message != null) handleFCMMessages(message);
        });

        // Foreground state:
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (!kIsWeb) {
            //_handleFCMMessages(message);
          }
        });

        // Background state:
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          handleFCMMessages(message);
        });
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Notification controller init error: $e');
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    handleFCMMessages(message);
  }

  static Future<void> handleFCMMessages(RemoteMessage message) async {
    if (message.data.containsKey('event')) {
      var eventId = message.data['event'];
      var yaNotify = YaNotification(
          id: 1,
          externalId: int.parse(eventId),
          title: '',
          createdAt: DateTime.now(),
          category: NotificationCategory.event);
      var func = await yaNotify.onTap;
      func();
    }
  }
}
