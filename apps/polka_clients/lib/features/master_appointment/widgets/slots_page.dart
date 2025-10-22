import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/master_appointment/controller/slots_cubit.dart';
import 'package:shared/shared.dart';

class SlotsPage extends StatelessWidget {
  const SlotsPage({super.key, required this.serviceId, required this.masterId});

  final int serviceId;
  final int masterId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SlotsCubit(masterId, serviceId),
      child: AppPage(
        appBar: ModalAppBar(title: 'Календарь'),
        child: BlocConsumer<SlotsCubit, SlotsState>(
          listener: (context, state) {
            if (state is SlotsError) Navigator.pop(context);
          },
          builder: (context, state) => switch (state) {
            SlotsInitial() => SizedBox.shrink(),
            SlotsLoading() => Center(child: LoadingIndicator()),
            SlotsLoaded(:final data) => SlotsView(slots: data),
            SlotsError(:final error) => Text(error),
          },
        ),
      ),
    );
  }
}

class SlotsView extends StatefulWidget {
  const SlotsView({super.key, required this.slots});

  final List<AvailableSlot> slots;

  @override
  State<SlotsView> createState() => _SlotsViewState();
}

class _SlotsViewState extends State<SlotsView> {
  AvailableSlot? selectedSlot;
  late final groupedSlots = groupSlots();

  Map<DateTime, List<AvailableSlot>> groupSlots() {
    final map = <DateTime, List<AvailableSlot>>{};

    widget.slots.sort((a, b) => a.datetime.compareTo(b.datetime));

    for (var slot in widget.slots) {
      map[slot.date] ??= [];
      map[slot.date]!.add(slot);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Text('Выбери дату и время', style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 32),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groupedSlots.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.formatDateOnly(),
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.value.map((slot) {
                            return GestureDetector(
                              onTap: () => setState(() => selectedSlot = slot),
                              child: _SlotButton(time: slot.startTime.toTimeString(), isSelected: selectedSlot == slot),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: AppTextButton.large(
            text: selectedSlot != null ? 'Выбрать ${(selectedSlot!.datetime.formatFull())}' : 'Выберите слот',
            onTap: () {
              if (selectedSlot != null) Navigator.pop(context, selectedSlot);
            },
            enabled: selectedSlot != null,
          ),
        ),
      ],
    );
  }
}

class _SlotButton extends StatelessWidget {
  final String time;
  final bool isSelected;
  const _SlotButton({required this.time, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFE6F3) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFFFF85C5) : Colors.transparent, width: 1),
      ),
      child: Center(
        child: Text(time, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  final String selectedDate;
  final String selectedTime;

  const NextPage({super.key, required this.selectedDate, required this.selectedTime});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: "Выбранный слот"),
      child: Center(child: Text("Вы выбрали: $selectedDate в $selectedTime")),
    );
  }
}
