part of 'old_bookings_cubit.dart';

final class BookingsState extends Equatable {
  const BookingsState({this.pending, this.upcoming, this.completed});

  final Map<int, Booking>? pending;
  final Map<int, Booking>? upcoming;
  final Map<int, Booking>? completed;

  BookingsState copyWith({
    ValueGetter<Map<int, Booking>?>? pending,
    ValueGetter<Map<int, Booking>?>? upcoming,
    ValueGetter<Map<int, Booking>?>? completed,
  }) => BookingsState(
    pending: pending != null ? pending() : this.pending,
    upcoming: upcoming != null ? upcoming() : this.upcoming,
    completed: completed != null ? completed() : this.completed,
  );

  @override
  List<Object?> get props => [pending, upcoming, completed];
}
