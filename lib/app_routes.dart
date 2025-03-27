
import 'package:get/get.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/home/home_view.dart';

class AppRoutes {
  static const initial = '/login';

  static final pages = [
    GetPage(
      name: '/home',
      page: () => const HomeView(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterView(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginView(),
    ),
  ];
}
