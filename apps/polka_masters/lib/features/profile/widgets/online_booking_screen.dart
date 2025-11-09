import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/profile/widgets/profile_screen.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class OnlineBookingScreen extends StatelessWidget {
  const OnlineBookingScreen({super.key, required this.masterId});

  final int masterId;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      future: () => Dependencies().masterRepository.getMasterLink(masterId),
      builder: (config) => _View(config: config),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.config});

  final OnlineBookingConfig config;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late var _config = widget.config.copyWith();

  void _updatePublicMode(OnlineBookingPublicMode mode) => setState(() {
    _config = _config.copyWith(publicMode: () => mode);
  });

  void _updateNightMode(bool value) => setState(() {
    _config = _config.copyWith(nightMode: () => value);
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Онлайн - запись'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.headingLarge('Онлайн - запись'),
              const SizedBox(height: 8),
              AppText(
                'Этот раздел регулирует доступность твоей записи в приложении POLKA, а также дает возможность размещать ссылку на онлайн-запись в социальных сетях',
                style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.iconsDefault),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.ext.theme.backgroundHover,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    Builder(
                      builder: (ctx) {
                        final master = ctx.watch<MasterScope>().master;
                        return Column(
                          children: [
                            BlotAvatar(avatarUrl: master.avatarUrl),
                            AppText(master.fullName, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge700),
                            AppText.secondary(
                              master.profession,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        );
                      },
                    ),
                    const MasterInfoWidget(),
                    GestureDetector(
                      onTap: () => Clipboard.setData(ClipboardData(text: _config.masterLink)).then((_) async {
                        showInfoSnackbar('Ссылка скопирована в буфер обмена');
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.ext.theme.backgroundDefault,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: AppText(_config.masterLink, overflow: TextOverflow.ellipsis)),
                            AppIcons.copy.icon(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const AppText.headingSmall('Настройки онлайн-записи'),
              const SizedBox(height: 8),
              AppText(
                'Настрой видимость твоей карточки и ссылки на онлайн-запись',
                style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.iconsDefault),
              ),
              const SizedBox(height: 24),
              RadioTheme(
                data: RadioThemeData(
                  backgroundColor: WidgetStateColor.resolveWith((_) => context.ext.theme.accentLight),
                  fillColor: WidgetStateColor.resolveWith((_) => context.ext.theme.accent),
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                ),
                child: RadioGroup(
                  groupValue: _config.publicMode,
                  onChanged: (_) {}, // This property is handled inside _RadioOption to override tap area
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      _RadioOption(
                        option: OnlineBookingPublicMode.public,
                        title: 'Публичная',
                        description: 'Доступна всем по ссылке',
                        onChanged: _updatePublicMode,
                      ),
                      _RadioOption(
                        option: OnlineBookingPublicMode.private,
                        title: 'Закрытая запись',
                        description:
                            'К тебе могут записаться только клиенты, которые добавлены в твою базу клиентов в приложении POLKA. Новые клиенты не могут записаться, если у их нет в твоей базе',
                        onChanged: _updatePublicMode,
                      ),
                      _RadioOption(
                        option: OnlineBookingPublicMode.off,
                        title: 'Выключена',
                        description: 'Онлайн-запись не активна',
                        onChanged: _updatePublicMode,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.max,
                spacing: 8,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Flexible(
                          child: AppText.headingSmall('Стоп-запись ночью', overflow: TextOverflow.ellipsis),
                        ),
                        GestureDetector(
                          onTap: () => showInfoBottomSheet(
                            context: context,
                            title: 'Стоп-запись ночью',
                            description:
                                'Если клиент зашел ночью в вашу онлайн-запись, то для записи ему недоступны утренние слоты предстоящего рабочего дня до 12:00.',
                            optionLabel: 'Понятно',
                            optionCallback: () {},
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                              child: AppIcons.alertCircle.icon(context, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSwitch(value: _config.nightMode, onChanged: _updateNightMode),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({required this.option, required this.title, required this.description, required this.onChanged});

  final OnlineBookingPublicMode option;
  final String title;
  final String description;
  final ValueChanged<OnlineBookingPublicMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(option),
      child: Material(
        color: Colors.transparent,
        child: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio(value: option),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(title, style: AppTextStyles.bodyLarge700),
                  AppText(
                    description,
                    style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.iconsDefault),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
