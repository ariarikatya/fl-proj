import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

// TODO: Add comments
abstract class OnboardingPageState<S extends StatefulWidget, C extends $OnboardingController, T extends Object?>
    extends State<S>
    with AutomaticKeepAliveClientMixin, OnboardingMixin<S, T> {
  final Map<String, ChangeNotifier> _notifiers = {};
  late final _stepNotfier = useNotifier<int>('__step__', 1);
  PageController? pageController;

  TextEditingController useController(String key) {
    _notifiers['controller-$key'] ??= TextEditingController();
    return _notifiers['controller-$key']! as TextEditingController;
  }

  ValueNotifier<V> useNotifier<V>(String key, V defaultValue) {
    _notifiers['notifier-$key'] ??= ValueNotifier<V>(defaultValue);
    return _notifiers['notifier-$key']! as ValueNotifier<V>;
  }

  List<Listenable> get dependencies;

  String? get continueLabel => null;

  bool get centerContent => false;

  void complete(C controller, T data);

  List<Widget> content();

  void _continueCallback({bool skip = false}) {
    final data = skip ? null : validateContinue();
    if (data != null || null is T) {
      FocusScope.of(context).unfocus();
      complete($OnboardingController.of<C>(context), data as T);
      final message = data == null ? '[onboarding] skipped $S' : '[onboarding] completed $S with data: $data';
      logger.info(message);
    }
  }

  Widget _continueBtn() => ValueListenableBuilder(
    valueListenable: continueNotifier,
    builder: (context, value, child) {
      return AppTextButton.large(text: continueLabel ?? 'Продолжить', onTap: _continueCallback, enabled: value != null);
    },
  );

  Widget _skibBtn() {
    assert(null is T, 'To enable skipping onboarding step, make sure that T type is nullable');
    return Center(
      child: GestureDetector(
        onTap: () => _continueCallback(skip: true),
        child: AppText(
          'Заполнить позже',
          style: AppTextStyles.bodyLarge.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    addContinueDependencies(dependencies);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pageController?.removeListener(_updateStep);
    pageController = $OnboardingController.of<C>(context).pageController;
    pageController?.addListener(_updateStep);
  }

  void _updateStep() {
    // 1.51 is a magic number:
    // +1 because we count from 1, not 0.
    // +0.5 for the page to change seamlessly mid-animation, not when the animation completes
    // +0.01 to make the number palindrome (cause I can)
    final newValue = ((pageController?.page ?? 0.0) + 1.51).toInt();
    if (newValue != _stepNotfier.value) _stepNotfier.value = newValue;
  }

  @override
  void dispose() {
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    pageController?.removeListener(_updateStep);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var child = SizedBox(
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: content()),
    );

    return AppPage(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: ValueListenableBuilder(
              valueListenable: _stepNotfier,
              builder: (context, value, child) => Stack(
                children: [
                  Center(child: AppText('Шаг $value', style: AppTextStyles.bodyLarge)),
                  if (value > 1)
                    GestureDetector(
                      onTap: $OnboardingController.of<C>(context).back,
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: AppIcons.arrowBack.icon()),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: centerContent
                ? Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: child),
                  )
                : SingleChildScrollView(padding: EdgeInsets.all(24), child: child),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                _continueBtn(),
                if (null is T) Padding(padding: EdgeInsets.only(top: 16), child: _skibBtn()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
