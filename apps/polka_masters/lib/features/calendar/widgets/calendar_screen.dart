import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/calendar_appbar.dart';
import 'package:polka_masters/features/calendar/widgets/calendar_drawer.dart';
import 'package:polka_masters/features/calendar/widgets/views/calendar_day_view.dart';
import 'package:polka_masters/features/calendar/widgets/views/calendar_month_view.dart';
import 'package:polka_masters/features/calendar/widgets/views/calendar_week_view.dart';
import 'package:polka_masters/features/clients_pages/client_page.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:shared/shared.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewMode = CalendarScope.of(context).viewMode;

    return Scaffold(
      appBar: CalendarAppbar(key: CalendarScope.of(context).calendarAppbarKey),
      drawer: CalendarDrawer(),
      body: SafeArea(
        bottom: false,
        child: switch (viewMode) {
          CalendarViewMode.month => CalendarMonthView(),
          CalendarViewMode.week => CalendarWeekView(),
          CalendarViewMode.day => CalendarDayView(),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToClientPage(context),
        backgroundColor: AppColors.accent,
        child: AppIcons.user.icon(
          color: AppColors.backgroundHover,
          size: 24,
        ),
      ),
    );
  }

  void _navigateToClientPage(BuildContext context) {
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
        serviceName: 'Окрашивание + стрижка + маникюр',
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClientPage(
          client: client,
          phoneNumber: '+79538230547',
          visits: visits,
        ),
      ),
    );
  }
}
