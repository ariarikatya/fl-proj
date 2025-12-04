import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/widgets/pick_service_page.dart';
import 'package:polka_masters/features/calendar/widgets/service_card.dart';
import 'package:polka_masters/features/contacts/widgets/contact_card.dart';
import 'package:polka_masters/features/contacts/widgets/pick_contact_screen.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

Future<Object?> showBookClientMbs({
  required BuildContext context,
  required DateTime start,
  bool canEditStartTime = true,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.ext.colors.white[100],
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _BookClientMbs(start: start, canEditStartTime: canEditStartTime),
  );
}

class _BookClientMbs extends StatefulWidget {
  const _BookClientMbs({required this.start, required this.canEditStartTime});

  final DateTime start;
  final bool canEditStartTime;

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

  void _setStartTime(Duration duration) => setState(() {
    _startTime = duration;
    _endTime = _startTime + (_service?.duration ?? _defaultDuration);
  });

  void _setEndTime(Duration duration) => setState(() => _endTime = duration);

  bool get validate => _bookTime || _contact != null && _service != null;

  bool _creating = false;

  void _createBooking() async {
    if (!validate || _creating) return;
    _creating = true;
    Result result;

    if (_bookTime) {
      result = await Dependencies().schedulesRepo.blockTime(
        date: widget.start,
        startTime: _startTime,
        endTime: _endTime ?? _startTime + (_service?.duration ?? _defaultDuration),
      );
    } else {
      result = await Dependencies().bookingsRepository.createBooking(
        contactId: _contact!.id,
        serviceId: _service!.id,
        date: widget.start,
        startTime: _startTime,
        endTime: _endTime ?? _startTime + (_service?.duration ?? _defaultDuration),
      );
    }
    if (mounted) {
      final scope = context.read<CalendarScope>();
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scope.dayViewKey.currentState?.animateToDuration(Duration(minutes: max(0, _startTime.inMinutes - 30)));
        });
      });
      context.ext.pop(result.unpack());
    }
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
            _DurationBlock(
              this,
              _service?.duration ?? _defaultDuration,
              showHeader: !_bookTime,
              canEditStartTime: widget.canEditStartTime,
            ),
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
        const SizedBox(height: 8),
        AppText(
          'Жми, если хочешь установить на это время перерыв, мы не будем показывать его  клиентам',
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
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
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
        ),
        const SizedBox(height: 16),
        if (state._contact == null)
          GestureDetector(
            onTap: state._pickContact,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.ext.colors.white[300], borderRadius: BorderRadius.circular(14)),
              child: Row(
                spacing: 8,
                children: [
                  FIcons.user.icon(context),
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
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
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
  const _DurationBlock(this.state, this.duration, {this.showHeader = true, this.canEditStartTime = true});

  final _BookClientMbsState state;
  final Duration duration;
  final bool showHeader;
  final bool canEditStartTime;

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
            style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
          ),
          const SizedBox(height: 16),
        ],
        FromToDurationPicker(
          startTime: state._startTime,
          endTime: state._endTime ?? state._startTime + duration,
          onStartTimeChanged: state._setStartTime,
          onEndTimeChanged: state._setEndTime,
          canEditStartTime: canEditStartTime,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
