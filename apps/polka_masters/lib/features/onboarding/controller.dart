import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';
import 'package:polka_masters/dependencies.dart';

typedef UserData = ({String name, String surname, String profession, String experience, String about});

typedef AvatarData = XFile;

typedef CategoryData = ServiceCategories;

typedef WorkplaceData = ({ServiceLocation location, Address address, List<XFile> photos});

typedef ServiceData = ({String serviceName, String description, int price, Duration duration, XFile image});

typedef ScheduleData = Schedule;

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
  OnboardingController(super.pageController, {super.key, required super.child, required this.phoneNumber});

  final profileRepo = Dependencies().profileRepository;
  final masterRepo = Dependencies().masterRepository;
  final onboardingData = OnboardingData();
  final String phoneNumber;

  final images = <String, String>{}; // Maps file name to image url from server

  void completeAboutPage(UserData data) => {onboardingData.userData = data, next()};

  void completeUploadAvatarPage(XFile image) => {
    onboardingData.avatarData = image,
    _uploadImages([image]),
    next(),
  };

  void completeWorkplacePage(WorkplaceData data) => {
    onboardingData.workplaceData = data,
    _uploadImages(data.photos),
    next(),
  };

  void completeServiceCategoryPage(CategoryData data) => {onboardingData.categoryData = data, next()};

  void completeServicePage(ServiceData? data) => {
    onboardingData.serviceData = data,
    if (data != null) _uploadImages([data.image]),
    next(),
  };

  void completeSchedulePage(ScheduleData? data) => {onboardingData.scheduleData = data, next()};

  void completePortfolioPage(PortfolioData? data) => {onboardingData.portfolioData = data, completeOnboarding()};

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
      avatarUrl: images[onboardingData.avatarData.name]!,
      portfolio: [], // Portfolio is uploaded further down below
      workplace: [...onboardingData.workplaceData.photos.map((xfile) => images[xfile.name]).nonNulls],
      categories: [onboardingData.categoryData],
      rating: 0,
      reviewsCount: 0,
      latitude: onboardingData.workplaceData.address.latitude,
      longitude: onboardingData.workplaceData.address.longitude,
    );
    final result = await profileRepo.createMasterProfile(phoneNumber, masterData);

    if (onboardingData.serviceData != null) {
      final data = onboardingData.serviceData!;
      final service = Service(
        id: -1,
        category: onboardingData.categoryData,
        description: data.description,
        location: onboardingData.workplaceData.location,
        resultPhotos: [?images[data.image.name]],
        title: data.serviceName,
        duration: data.duration,
        price: data.price,
      );
      await masterRepo.createMasterService(service);
    }

    if (onboardingData.scheduleData != null) {
      await masterRepo.createMasterSchedule(onboardingData.scheduleData!);
    }

    if (onboardingData.portfolioData?.isNotEmpty == true) {
      await masterRepo.uploadPortfolioPhotos(onboardingData.portfolioData!);
    }

    result.when(
      ok: (master) => Dependencies().authController.completeOnboarding(master),
      err: (err, st) => handleError,
    );
  }

  Future<void> _uploadImages(List<XFile> xfiles) async {
    if (xfiles.isEmpty) return;
    final imagesResult = await profileRepo.uploadPhotos(xfiles);
    imagesResult.maybeWhen(ok: (data) => images.addAll(data));
  }
}
