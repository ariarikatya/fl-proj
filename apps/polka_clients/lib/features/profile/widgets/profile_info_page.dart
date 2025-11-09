import 'package:flutter/material.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:shared/shared.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  late final _controllers = List.generate(3, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  late Client client;
  late String phoneNumber;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    client = ClientScope.of(context).client;
    phoneNumber = ClientScope.of(context).phoneNumber;
    _controllers[0].text = client.fullName;
    _controllers[1].text = client.city;
    _controllers[2].text = client.email ?? '';
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final valid = _formKey.currentState?.validate();
    if (valid != true) return;

    final parts = _controllers[0].text.split(' ');
    final city = _controllers[1].text.trim();
    final email = _controllers[2].text.trim().isNotEmpty ? _controllers[2].text.trim() : null;
    _updateProfileInfo(parts[0], parts[1], city, email);
  }

  void _updateProfileInfo(String name, String surname, String city, String? email) async {
    if (_saving) return;
    _saving = true;
    logger.debug('saving profile info');

    final profileRepo = Dependencies().profileRepository;
    final result = await profileRepo.updateAccountInfo(name, surname, city, email);

    result.when(
      ok: (newCategories) {
        ClientScope.of(context).updateClient(
          (client) =>
              client.copyWith(firstName: () => name, lastName: () => surname, city: () => city, email: () => email),
        );
        showSuccessSnackbar('Изменения успешно сохранены');
        if (mounted) context.ext.pop();
      },
      err: (err, st) => handleError(err, st),
    );

    _saving = false;
    logger.debug('saved profile info');
  }

  Future<void> _pickCity() async {
    final city = await context.ext.push<City>(CityPage(initialCity: _controllers[1].text));
    if (city != null && mounted) {
      _controllers[1].text = city.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Личные данные'),
      child: Stack(
        children: [
          Form(
            autovalidateMode: AutovalidateMode.onUnfocus,
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const AppText('Расскажи о себе', style: AppTextStyles.headingSmall),
                  AppTextFormField(
                    labelText: 'Имя Фамилия',
                    controller: _controllers[0],
                    validator: Validators.fullName,
                  ),
                  GestureOverrideWidget(
                    onTap: _pickCity,
                    child: AppTextFormField(
                      labelText: 'Твой город',
                      controller: _controllers[1],
                      validator: Validators.isNotEmpty,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppText('Контактная информация', style: AppTextStyles.headingSmall),
                  _MockReadOnlyPhoneTextField(phoneNumber: phoneNumber),
                  AppTextFormField(labelText: 'E-mail', controller: _controllers[2], validator: Validators.email),
                  const SizedBox(height: 32),
                  const _DeleteAccountButton(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: AppTextButton.large(text: 'Сохранить изменения', onTap: _save),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  void _deleteAccount(BuildContext context) async {
    final delete = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь удалить свой аккаунт?\nЭто действие нельзя будет отменить',
      acceptText: 'Удалить',
      declineText: 'Отменить',
    );
    if (delete == true) {
      await Dependencies().authRepository.deleteAccount();
      if (context.mounted) AuthenticationScope.of(context).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _deleteAccount(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          AppIcons.trash.icon(context),
          AppText('Удалить мой аккаунт', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MockReadOnlyPhoneTextField extends StatefulWidget {
  const _MockReadOnlyPhoneTextField({required this.phoneNumber});
  final String phoneNumber;

  @override
  State<_MockReadOnlyPhoneTextField> createState() => _MockReadOnlyPhoneTextFieldState();
}

class _MockReadOnlyPhoneTextFieldState extends State<_MockReadOnlyPhoneTextField> {
  late final _controller = TextEditingController(text: widget.phoneNumber);

  @override
  void initState() {
    _controller.text = phoneFormatter.maskText(widget.phoneNumber);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(controller: _controller, enabled: false, readOnly: true, labelText: 'Номер телефона');
  }
}
