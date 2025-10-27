import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:shared/shared.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({
    super.key,
    required this.client,
    required this.phoneNumber,
    required this.visits,
  });

  final Client client;
  final String phoneNumber;
  final List<Booking> visits;

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Client client;
  late final _nameController = TextEditingController();
  late final _cityController = TextEditingController();
  late final _birthdayController = TextEditingController();
  late final _emailController = TextEditingController();
  late final _notesController = TextEditingController();
  DateTime? _lastSnackbarAt;

  @override
  void initState() {
    super.initState();
    client = widget.client;
    _nameController.text = client.fullName;
    _cityController.text = client.city;
    _emailController.text = client.email ?? '';
    _notesController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveClient(void Function() apply) {
    setState(() => apply());
    _showSavedSnackbar();
  }

  void _showSavedSnackbar() {
    final now = DateTime.now();
    if (_lastSnackbarAt == null ||
        now.difference(_lastSnackbarAt!) > Duration(seconds: 1)) {
      _lastSnackbarAt = now;
      showSuccessSnackbar('Изменения успешно сохранены');
    }
  }

  Widget _buildContent(List<Booking> visits) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твой клиент'),
      backgroundColor: AppColors.backgroundDefault,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            _ClientHeader(client: client, visitsCount: visits.length),

            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                spacing: 4,
                children: [
                  Expanded(
                    child: SizedBox(
                      child: AppTextButtonSecondary.large(
                        text: 'Чат',
                        onTap: () => _openChatWithClient(
                          context,
                          client.id,
                          client.fullName,
                          client.avatarUrl,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: AppTextButtonSecondary.large(
                        text: 'Позвонить',
                        onTap: () => _callClient(client.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                AppText(
                  'Персональная информация',
                  style: AppTextStyles.headingSmall,
                ),
                AppTextFormField(
                  labelText: 'Имя и Фамилия',
                  controller: _nameController,
                  onFieldSubmitted: (value) {
                    if (!mounted) return;
                    final parts = value.trim().split(' ');
                    if (parts.length >= 2) {
                      _saveClient(() {
                        client = client.copyWith(
                          firstName: () => parts[0],
                          lastName: () => parts.sublist(1).join(' '),
                        );
                      });
                    }
                  },
                ),
                AppTextFormField(
                  labelText: 'Город',
                  controller: _cityController,
                  onFieldSubmitted: (value) {
                    if (!mounted) return;
                    _saveClient(
                      () => client = client.copyWith(city: () => value.trim()),
                    );
                  },
                ),
                AppTextFormField(
                  labelText: 'День рождения',
                  controller: _birthdayController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _DateInputFormatter(),
                  ],
                  onFieldSubmitted: (_) {
                    if (!mounted) return;
                    _saveClient(() {});
                  },
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                AppText('Контакты', style: AppTextStyles.headingSmall),
                AppTextFormField(
                  labelText: 'Номер телефона',
                  controller: TextEditingController(
                    text: mockPhoneFormatter.maskText(widget.phoneNumber),
                  ),
                  enabled: false,
                  readOnly: true,
                ),
                AppTextFormField(
                  labelText: 'E-mail',
                  controller: _emailController,
                  onFieldSubmitted: (value) {
                    if (!mounted) return;
                    _saveClient(
                      () => client = client.copyWith(email: () => value.trim()),
                    );
                  },
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                AppText('Заметки', style: AppTextStyles.headingSmall),
                Stack(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 104,
                        maxHeight: 104,
                      ),
                      child: AppTextFormField(
                        labelText: 'Например, аллергия на коллаген',
                        controller: _notesController,
                        maxLines: 4,
                        onFieldSubmitted: (_) {
                          if (!mounted) return;
                          _saveClient(() {});
                        },
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: GestureDetector(
                        onTap: () {
                          _notesController.clear();
                          if (mounted) _saveClient(() {});
                        },
                        child: AppIcons.close.icon(size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                AppText('История посещений', style: AppTextStyles.headingSmall),
                if (visits.isEmpty)
                  AppText(
                    'У этого клиента еще нет посещений, может ты сможешь ей что-то интересное',
                    style: AppTextStyles.bodyLarge2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ...visits.map((b) => _VisitTile(booking: b)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Booking>? directVisits = widget.visits.isNotEmpty
        ? widget.visits
        : null;
    if (directVisits != null) {
      return _buildContent(directVisits);
    }
    return LoadDataPage<List<Booking>>(
      title: 'Твой клиент',
      onErrorBehavior: OnErrorBehavior.showErrorPage,
      future: () => Dependencies().masterRepository.getAllBookings(),
      builder: (bookings) {
        final visits = bookings.where((b) => b.clientId == client.id).toList();
        return _buildContent(visits);
      },
    );
  }

  Future<void> _openChatWithClient(
    BuildContext context,
    int clientId,
    String name,
    String avatar,
  ) async {
    final chats = blocs.get<ChatsCubit>(context);
    await chats.loadChats();
    if (!context.mounted) return;
  }

  Future<void> _callClient(int clientId) async {
    final phone = widget.phoneNumber.replaceAll('+', '').replaceAll(' ', '');
    try {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: AppText('Звонок'),
          content: AppText('Номер телефона: +$phone'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: AppText('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e, st) {
      handleError(e, st);
    }
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length > 10) {
      return oldValue;
    }

    String formatted = '';
    int digitCount = 0;

    for (int i = 0; i < text.length; i++) {
      if (RegExp(r'\d').hasMatch(text[i])) {
        formatted += text[i];
        digitCount++;

        if (digitCount == 2 || digitCount == 4) {
          formatted += '.';
        }
      }
    }

    if (formatted.endsWith('.') && digitCount != 2 && digitCount != 4) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.client, required this.visitsCount});

  final Client client;
  final int visitsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          BlotAvatar(avatarUrl: client.avatarUrl, size: 160),
          AppText(
            client.fullName,
            style: AppTextStyles.headingLarge,
            textAlign: TextAlign.center,
          ),
          AppText(
            'Клиент',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppEmojis.lollipop.icon(),
                  SizedBox(width: 4),
                  AppText(
                    client.city,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppEmojis.scissors.icon(),
                  SizedBox(width: 4),
                  AppText(
                    '$visitsCount ${_pluralizeVisits(visitsCount)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _pluralizeVisits(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) {
    return 'посещение';
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'посещения';
  }
  return 'посещений';
}

class _VisitTile extends StatelessWidget {
  const _VisitTile({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final hours = booking.duration.inHours;
    final minutes = booking.duration.inMinutes % 60;
    final durationLabel = minutes == 0
        ? '$hours ч'
        : '${hours > 0 ? '$hours ч ' : ''}$minutes м';

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.backgroundHover, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageClipped(
            width: 48,
            height: 48,
            borderRadius: 10,
            imageUrl: booking.serviceImageUrl,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  AppText(booking.serviceName, style: AppTextStyles.bodyLarge),
                  Row(
                    spacing: 4,
                    children: [
                      AppIcons.clock.icon(
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      AppText(
                        durationLabel,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4),
                      AppText(
                        '|',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4),
                      AppText(
                        '₽${booking.price}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              AppText(
                booking.date.toDateString('.'),
                style: AppTextStyles.bodyMedium,
              ),
              AppText(
                booking.status.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: booking.status.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClientPageMock extends StatelessWidget {
  const ClientPageMock({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Client(
      id: 1,
      firstName: 'Саша',
      lastName: 'Аксентьева',
      city: 'Екатеринбург',
      services: const [],
      preferredServices: const [],
      avatarUrl: '',
      email: 'sashamore@gmail.com',
    );
    final now = DateTime.now();
    final visits = <Booking>[
      Booking(
        id: 10,
        clientId: client.id,
        masterId: 100,
        serviceId: 50,
        serviceName:
            'Окрашивание + стрижка + мелирование + тонирование + маникюр',
        masterName: 'Вы',
        price: 4500,
        status: BookingStatus.canceled,
        date: now.subtract(const Duration(days: 20)),
        createdAt: now.subtract(const Duration(days: 25)),
        startTime: const Duration(hours: 10, minutes: 30),
        endTime: const Duration(hours: 12),
        serviceImageUrl: null,
        masterAvatarUrl: null,
        clientNotes: '',
        masterNotes: '',
        reviewSent: false,
      ),
      Booking(
        id: 11,
        clientId: client.id,
        masterId: 100,
        serviceId: 51,
        serviceName: 'Окрашивание',
        masterName: 'Вы',
        price: 2500,
        status: BookingStatus.completed,
        date: now.subtract(const Duration(days: 18)),
        createdAt: now.subtract(const Duration(days: 18)),
        startTime: const Duration(hours: 14),
        endTime: const Duration(hours: 16),
        serviceImageUrl: null,
        masterAvatarUrl: null,
        clientNotes: '',
        masterNotes: '',
        reviewSent: true,
      ),
    ];

    return ClientPage(
      client: client,
      phoneNumber: '+79538230547',
      visits: visits,
    );
  }
}
