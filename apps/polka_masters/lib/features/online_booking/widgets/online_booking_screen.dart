import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/features/profile/widgets/profile_screen.dart';
import 'package:polka_masters/features/online_booking/controller/online_booking_cubit.dart';
import 'package:polka_masters/scopes/master_model.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class OnlineBookingScreen extends StatefulWidget {
  const OnlineBookingScreen({super.key});

  @override
  State<OnlineBookingScreen> createState() => _OnlineBookingScreenState();
}

class _OnlineBookingScreenState extends State<OnlineBookingScreen> with TickerProviderStateMixin {
  late final _controller = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      backgroundColor: context.ext.colors.white[200],
      appBar: const CustomAppBar(title: 'Настройки записи', simplified: true),
      child: Column(
        children: [
          AppTabBar(
            controller: _controller,
            dividerColor: context.ext.colors.white[200],
            backgroundColor: context.ext.colors.white[200],
            tabs: [
              const Tab(text: 'Общие настройки'),
              const Tab(text: 'Онлайн-запись'),
            ],
          ),
          Expanded(
            child: TabBarView(controller: _controller, children: const [_GeneralSettingsView(), _OnlineBookingView()]),
          ),
        ],
      ),
    );
  }
}

class _GeneralSettingsView extends StatelessWidget {
  const _GeneralSettingsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.ext.colors;
    final styles = context.ext.textTheme;

    return AppPage(
      child: DataBuilder<OnlineBookingCubit, OnlineBookingConfig>(
        dataBuilder: (_, config) => SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppText('Настройка записи', style: styles.headlineMedium),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: RadioGroup(
                    groupValue: config.visibility,
                    onChanged: (_) {}, // This property is handled inside _RadioOption to override tap area
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        _RadioOption(
                          option: OnlineBookingVisibility.public,
                          title: 'Публичный профиль',
                          description: 'Твой профиль доступен всем для записи',
                          onChanged: context.read<OnlineBookingCubit>().changeVisibility,
                        ),
                        _RadioOption(
                          option: OnlineBookingVisibility.closed,
                          title: 'Закрытая запись',
                          description:
                              'К тебе могут записаться только клиенты, которые добавлены в твою базу клиентов в приложении POLKA. Новые клиенты не могут записаться, если их нет в твоей базе',
                          onChanged: context.read<OnlineBookingCubit>().changeVisibility,
                        ),
                        _RadioOption(
                          option: OnlineBookingVisibility.off,
                          title: 'Скрыть профиль',
                          description: 'Твой профиль скрыт в приложении POLKA и онлайн-запись закрыта',
                          onChanged: context.read<OnlineBookingCubit>().changeVisibility,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: colors.white[300]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Column(
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        spacing: 8,
                        children: [
                          Expanded(
                            child: AppText(
                              'Блок ночной записи',
                              overflow: TextOverflow.ellipsis,
                              style: styles.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          AppSwitch(
                            value: config.nightStop,
                            onChanged: (_) => context.read<OnlineBookingCubit>().toggleNightStop(),
                          ),
                        ],
                      ),
                      AppText(
                        'Ежедневно после 23:00 текущего дня клиентам недоступна запись на утро предстоящего дня до 12:00',
                        style: styles.bodyMedium?.copyWith(color: colors.black[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnlineBookingView extends StatelessWidget {
  const _OnlineBookingView();

  @override
  Widget build(BuildContext context) {
    final styles = context.ext.textTheme;

    return AppPage(
      child: DataBuilder<OnlineBookingCubit, OnlineBookingConfig>(
        dataBuilder: (_, config) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Онлайн-запись', style: styles.headlineMedium),
                const SizedBox(height: 16),
                AppText(
                  'Размести ссылку на онлайн-запись в социальных сетях',
                  style: styles.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.ext.colors.white[300],
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  child: Column(
                    spacing: 16,
                    children: [
                      Builder(
                        builder: (ctx) {
                          final master = ctx.watch<MasterModel>().master;
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
                        onTap: () => Clipboard.setData(ClipboardData(text: config.publicLink)).then((_) async {
                          showInfoSnackbar('Ссылка скопирована в буфер обмена');
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.ext.colors.white[100],
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: AppText(config.publicLink, overflow: TextOverflow.ellipsis)),
                              FIcons.copy.icon(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({required this.option, required this.title, required this.description, required this.onChanged});

  final OnlineBookingVisibility option;
  final String title;
  final String description;
  final ValueChanged<OnlineBookingVisibility> onChanged;

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
            IgnorePointer(ignoring: true, child: Radio(value: option)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AppText(title, style: AppTextStyles.bodyLarge700),
                  AppText(
                    description,
                    style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
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
