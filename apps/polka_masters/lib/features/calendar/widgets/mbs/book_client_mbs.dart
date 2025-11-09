import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/widgets/pick_service_page.dart';
import 'package:polka_masters/features/calendar/widgets/service_card.dart';
import 'package:polka_masters/features/contacts/widgets/contact_card.dart';
import 'package:polka_masters/features/contacts/widgets/pick_contact_screen.dart';
import 'package:shared/shared.dart';

Future<void> showBookClientMbs({required BuildContext context, required DateTime start}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.ext.theme.backgroundDefault,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _BookClientMbs(start: start),
  );
}

class _BookClientMbs extends StatefulWidget {
  const _BookClientMbs({required this.start});

  final DateTime start;

  @override
  State<_BookClientMbs> createState() => _BookClientMbsState();
}

class _BookClientMbsState extends State<_BookClientMbs> {
  bool _bookTime = false;
  Service? _service;
  Contact? _contact;
  late Duration _startTime = Duration(hours: widget.start.hour, minutes: widget.start.minute);
  Duration? _endTime;

  static const _defaultDuration = Duration(minutes: 60);

  void _pickService() async {
    final service = await context.ext.push<Service>(const PickServicePage());
    if (service != null) {
      setState(() => _service = service);
    }
  }

  void _pickContact() async {
    // final contact = await context.ext.push<Contact>(PickContactScreen(contact: _contact));
    final contact = await context.ext.push<Contact>(const PickContactScreenAlt());
    if (contact != null) {
      setState(() => _contact = contact);
    }
  }

  void _setBookTime(bool value) => setState(() => _bookTime = value);
  void _setStartTime(Duration duration) => setState(() => _startTime = duration);
  void _setEndTime(Duration duration) => setState(() => _endTime = duration);

  bool get validate => _bookTime || _contact != null && _service != null;

  void _createBooking() async {
    if (!validate) return;

    if (_bookTime) {
      await Dependencies().bookingsRepository.blockTime(
        date: widget.start,
        startTime: _startTime,
        endTime: _endTime ?? _startTime + (_service?.duration ?? _defaultDuration),
      );
    } else {
      await Dependencies().bookingsRepository.createBooking(
        contactId: _contact!.id,
        serviceId: _service!.id,
        date: widget.start,
        startTime: _startTime,
        endTime: _endTime ?? _startTime + (_service?.duration ?? _defaultDuration),
      );
    }
    if (mounted) context.ext.pop();
  }

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      expandContent: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText('Создай новую запись', textAlign: TextAlign.center, style: AppTextStyles.headingLarge),
          const SizedBox(height: 24),
          _BookTimeBlock(this),
          if (!_bookTime) ...[_ContactBlock(this), _ServiceBlock(this)],
          if (_service != null || _bookTime)
            _DurationBlock(this, _service?.duration ?? _defaultDuration, showHeader: !_bookTime),
          const SizedBox(height: 8),
          AppTextButton.large(enabled: validate, text: 'Создать запись', onTap: _createBooking),
        ],
      ),
    );
  }
}

class _BookTimeBlock extends StatelessWidget {
  const _BookTimeBlock(this.state);

  final _BookClientMbsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText('Занять время', style: AppTextStyles.headingSmall),
            AppSwitch(value: state._bookTime, onChanged: state._setBookTime),
          ],
        ),
        AppText(
          'Жми, если хочешь установить на это время перерыв, мы не будем показывать его  клиентам',
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.textSecondary),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock(this.state);

  final _BookClientMbsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Кто записан на услугу?', style: AppTextStyles.headingSmall),
        const SizedBox(height: 8),
        AppText(
          'Жми на поле внизу, чтобы выбрать клиента из списка или создай запись вручную',
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.textSecondary),
        ),
        const SizedBox(height: 16),
        if (state._contact == null)
          GestureDetector(
            onTap: state._pickContact,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.ext.theme.backgroundHover,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                spacing: 8,
                children: [
                  AppIcons.user.icon(context),
                  const Flexible(child: AppText.secondary('Выбери клиента')),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: state._pickContact,
            child: ContactCard(contact: state._contact!),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ServiceBlock extends StatelessWidget {
  const _ServiceBlock(this.state);

  final _BookClientMbsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText('Какая услуга?', style: AppTextStyles.headingSmall),
            if (state._service != null) AppLinkButton(text: 'Изменить', onTap: state._pickService),
          ],
        ),
        const SizedBox(height: 4),
        AppText(
          'Выбери услугу из твоего списка',
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.textSecondary),
        ),
        const SizedBox(height: 16),
        if (state._service == null)
          AppTextButton.large(text: 'Выбери услугу', onTap: state._pickService)
        else
          ServiceCard(state._service!),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DurationBlock extends StatelessWidget {
  const _DurationBlock(this.state, this.duration, {this.showHeader = true});

  final _BookClientMbsState state;
  final Duration duration;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          const AppText('Когда?', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          AppText(
            'Подтверди время, окончание услуги сформируется автоматически после выбора',
            style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.textSecondary),
          ),
          const SizedBox(height: 16),
        ],
        FromToDurationPicker(
          startTime: state._startTime,
          endTime: state._endTime ?? state._startTime + duration,
          onStartTimeChanged: state._setStartTime,
          onEndTimeChanged: state._setEndTime,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
