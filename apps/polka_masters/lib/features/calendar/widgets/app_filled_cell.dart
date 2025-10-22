import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class AppFilledCell<T extends Object?> extends StatelessWidget {
  /// Date of current cell.
  final DateTime date;

  /// List of events on for current date.
  final List<CalendarEventData<T>> events;

  /// Called when user taps on any event tile.
  final TileTapCallback<T>? onTileTap;

  /// Called when user long press on any event tile.
  final TileTapCallback<T>? onTileLongTap;

  /// Called when user double tap on any event tile.
  final TileTapCallback<T>? onTileDoubleTap;

  /// defines that [date] is in current month or not.
  final bool isInMonth;

  /// This class will defines how cell will be displayed.
  /// This widget will display all the events as tile below date title.
  const AppFilledCell({
    super.key,
    required this.date,
    required this.events,
    this.isInMonth = false,
    this.onTileTap,
    this.onTileLongTap,
    this.onTileDoubleTap,
  });

  const AppFilledCell.factory(
    DateTime $date,
    List<CalendarEventData<T>> $event,
    bool $isToday,
    bool $isInMonth,
    bool $hideDaysNotInMonth, {
    super.key,
    this.onTileTap,
    this.onTileLongTap,
    this.onTileDoubleTap,
  }) : date = $date,
       events = $event,
       isInMonth = $isInMonth;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isInMonth ? AppColors.backgroundDefault : AppColors.backgroundHover;

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          SizedBox(height: 8),
          Center(
            child: AppText(
              '${date.day}',
              style: AppTextStyles.bodyLarge2.copyWith(
                color: isInMonth ? AppColors.textPrimary : AppColors.textPlaceholder,
              ),
              maxLines: 1,
            ),
          ),
          if (events.isNotEmpty)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 5.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      events.length,
                      (index) => GestureDetector(
                        onTap: () => onTileTap?.call(events[index], date),
                        onLongPress: () => onTileLongTap?.call(events[index], date),
                        onDoubleTap: () => onTileDoubleTap?.call(events[index], date),
                        child: Container(
                          decoration: BoxDecoration(
                            color: events[index].color,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
                          padding: const EdgeInsets.all(2.0),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  events[index].title,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style:
                                      events[index].titleStyle ??
                                      TextStyle(color: events[index].color.accent, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
