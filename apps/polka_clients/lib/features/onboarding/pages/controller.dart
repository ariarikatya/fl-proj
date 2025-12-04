import 'package:shared/shared.dart';
import 'package:polka_clients/dependencies.dart';

typedef UserData = ({String firstName, String lastName, String city});

typedef CategoriesData = List<ServiceCategories>;

class UserSetupData {
  UserData? userData;
  CategoriesData? interests;
}

class OnboardingController extends $OnboardingController {
  OnboardingController(
    super.pageController, {
    super.key,
    required super.child,
    required this.phoneNumber,
    super.stepsCount = 3,
  });

  final profileRepo = Dependencies().profileRepository;
  final setupData = UserSetupData();
  final String phoneNumber;

  void completeAboutPage(UserData data) => {setupData.userData = data, next()};

  void completeInterestsPage(CategoriesData data) => {setupData.interests = data, next()};

  Future<void> completeOnboarding() async {
    final clientData = Client(
      id: -1,
      firstName: setupData.userData?.firstName ?? 'Имя',
      lastName: setupData.userData?.lastName ?? '',
      city: setupData.userData?.city ?? '',
      preferredServices: setupData.interests ?? [],
      avatarUrl: '',
      email: null,
    );

    final result = await profileRepo.createClientProfile(phoneNumber, clientData);
    result.when(
      ok: (client) async {
        await Dependencies().authController.completeOnboarding();
        Dependencies().analytics.reportEvent('onboarding_completed', params: client.toJson());
      },
      err: (err, st) => throw err,
    );
  }
}
