import 'package:polka_masters/features/schedules/widgets/schedule_mbs.dart';
import 'package:shared/shared.dart';
import 'package:polka_masters/dependencies.dart';

typedef UserData = ({String name, String surname, String profession, String experience, String about});

typedef AvatarData = String;

typedef CategoryData = ServiceCategories;

typedef WorkplaceData = ({ServiceLocation location, Address address, List<String> photos});

typedef ServiceData = ({String serviceName, int price, Duration duration, String imageUrl});

typedef ScheduleData = ({Schedule schedule, List<ScheduleBreak> breaks});

typedef PortfolioData = List<String>;

class OnboardingData {
  late UserData userData;
  late AvatarData avatarData;
  late CategoryData categoryData;
  late WorkplaceData workplaceData;
  late ServiceData? serviceData;
  late ScheduleData? scheduleData;
  late PortfolioData? portfolioData;
}

class OnboardingController extends $OnboardingController {
  OnboardingController(
    super.pageController, {
    super.key,
    required super.child,
    required this.phoneNumber,
    super.stepsCount = 7,
  });

  final profileRepo = Dependencies().profileRepository;
  final masterRepo = Dependencies().masterRepository;
  final schedulesRepo = Dependencies().schedulesRepo;
  final onboardingData = OnboardingData();
  final String phoneNumber;

  void completeAboutPage(UserData data) => {onboardingData.userData = data, next()};

  void completeUploadAvatarPage(String image) => {onboardingData.avatarData = image, next()};

  void completeWorkplacePage(WorkplaceData data) => {onboardingData.workplaceData = data, next()};

  void completeServiceCategoryPage(CategoryData data) => {onboardingData.categoryData = data, next()};

  void completeServicePage(ServiceData? data) => {onboardingData.serviceData = data, next()};

  void completeSchedulePage(ScheduleData? data) => {onboardingData.scheduleData = data, next()};

  Future<void> completePortfolioPage(PortfolioData? data) {
    onboardingData.portfolioData = data;
    return completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    final masterData = Master(
      id: -1,
      firstName: onboardingData.userData.name,
      lastName: onboardingData.userData.surname,
      profession: onboardingData.userData.profession,
      experience: onboardingData.userData.experience,
      about: onboardingData.userData.about,
      city: onboardingData.workplaceData.address.city,
      address: onboardingData.workplaceData.address.address,
      avatarUrl: onboardingData.avatarData,
      portfolio: [], // Portfolio is uploaded further down below
      workplace: onboardingData.workplaceData.photos,
      categories: [onboardingData.categoryData],
      rating: 0,
      reviewsCount: 0,
      latitude: onboardingData.workplaceData.address.latitude,
      longitude: onboardingData.workplaceData.address.longitude,
      location: onboardingData.workplaceData.location,
    );
    final result = await profileRepo.createMasterProfile(phoneNumber, masterData);

    if (onboardingData.serviceData != null) {
      final data = onboardingData.serviceData!;
      final service = Service(
        id: -1,
        category: onboardingData.categoryData,
        resultPhotos: [data.imageUrl],
        title: data.serviceName,
        duration: data.duration,
        price: data.price,
        cost: null,
      );
      await [
        masterRepo.createService(service),
        Dependencies().analytics.reportEvent('onboarding_service_created'),
      ].wait;
    }

    if (onboardingData.scheduleData != null) {
      await [
        schedulesRepo.createSchedule(onboardingData.scheduleData!.schedule),
        Dependencies().analytics.reportEvent('onboarding_schedule_created'),
      ].wait;

      for (var $break in onboardingData.scheduleData!.breaks) {
        schedulesRepo
            .blockTimePeriod(
              startDate: onboardingData.scheduleData!.schedule.periodStart.dateOnly,
              endDate: onboardingData.scheduleData!.schedule.periodEnd.dateOnly,
              startTime: $break.start,
              endTime: $break.end,
            )
            .ignore();
      }
    }

    if (onboardingData.portfolioData?.isNotEmpty == true) {
      await masterRepo.uploadPortfolioPhotos(onboardingData.portfolioData!);
    }

    result.when(
      ok: (master) async {
        await Dependencies().authController.completeOnboarding();
        Dependencies().analytics.reportEvent('onboarding_completed', params: master.toJson());
      },
      err: (err, st) => handleError,
    );
  }
}
