
import 'package:get/get.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/home/home_view.dart';
import 'features/onboarding/views/welcome_view.dart';
import 'features/onboarding/views/create_team_view.dart';

class AppRoutes {
  static const initial = '/login';

  static final pages = [
    GetPage(
      name: '/welcome',
      page: () => const WelcomeView(),
    ),
    GetPage(
      name: '/create-team',
      page: () => const CreateTeamView()
    ),
    GetPage(
      name: '/join-team',
      page: () => const Placeholder(), // wordt vervangen
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
    ),
    GetPage(
      name: '/welcome',
      page: () => const WelcomeView(),
    ),
    GetPage(
      name: '/create-team',
      page: () => const CreateTeamView()
    ),
    GetPage(
      name: '/join-team',
      page: () => const Placeholder(), // wordt vervangen
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterView(),
    ),
    GetPage(
      name: '/welcome',
      page: () => const WelcomeView(),
    ),
    GetPage(
      name: '/create-team',
      page: () => const CreateTeamView()
    ),
    GetPage(
      name: '/join-team',
      page: () => const Placeholder(), // wordt vervangen
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
    ),
    GetPage(
      name: '/welcome',
      page: () => const WelcomeView(),
    ),
    GetPage(
      name: '/create-team',
      page: () => const CreateTeamView()
    ),
    GetPage(
      name: '/join-team',
      page: () => const Placeholder(), // wordt vervangen
    ),
    GetPage(
      name: '/login',
      page: () => const LoginView(),
    ),
  ];
}
