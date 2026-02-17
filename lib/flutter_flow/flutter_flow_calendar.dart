import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'flutter_flow_util.dart';

DateTime kFirstDay = DateTime(1970, 1, 1);
DateTime kLastDay = DateTime(2100, 1, 1);

extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59);
}

class FlutterFlowCalendar extends StatefulWidget {
  const FlutterFlowCalendar({
    super.key,
    required this.color,
    this.onChange,
    this.initialDate,
    this.weekFormat = false,
    this.weekStartsMonday = false,
    this.twoRowHeader = false,
    this.iconColor,
    this.dateStyle,
    this.dayOfWeekStyle,
    this.inactiveDateStyle,
    this.selectedDateStyle,
    this.titleStyle,
    this.rowHeight,
    this.locale,
    this.eventLoader,
    this.markerBuilder,
    this.animateDays = false,
    this.headerWrapper,
    this.animationBaseDelayMs = 100,
    this.rowStaggerMs = 120,
  });

  final bool weekFormat;
  final bool weekStartsMonday;
  final bool twoRowHeader;
  final Color color;
  final void Function(DateTimeRange?)? onChange;
  final DateTime? initialDate;
  final Color? iconColor;
  final TextStyle? dateStyle;
  final TextStyle? dayOfWeekStyle;
  final TextStyle? inactiveDateStyle;
  final TextStyle? selectedDateStyle;
  final TextStyle? titleStyle;
  final double? rowHeight;
  final String? locale;
  final List<dynamic> Function(DateTime)? eventLoader;
  final Widget Function(BuildContext, DateTime, List<dynamic>)? markerBuilder;
  final bool animateDays;
  final Widget Function(Widget header)? headerWrapper;
  final int animationBaseDelayMs;
  final int rowStaggerMs;

  @override
  State<StatefulWidget> createState() => _FlutterFlowCalendarState();
}

class _FlutterFlowCalendarState extends State<FlutterFlowCalendar> {
  late DateTime focusedDay;
  late DateTime selectedDay;
  late DateTimeRange selectedRange;

  @override
  void initState() {
    super.initState();
    focusedDay = widget.initialDate ?? DateTime.now();
    selectedDay = widget.initialDate ?? DateTime.now();
    selectedRange = DateTimeRange(
      start: selectedDay.startOfDay,
      end: selectedDay.endOfDay,
    );
    SchedulerBinding.instance
        .addPostFrameCallback((_) => setSelectedDay(selectedRange.start));
  }

  CalendarFormat get calendarFormat =>
      widget.weekFormat ? CalendarFormat.week : CalendarFormat.month;

  StartingDayOfWeek get startingDayOfWeek => widget.weekStartsMonday
      ? StartingDayOfWeek.monday
      : StartingDayOfWeek.sunday;

  Color get color => widget.color;

  Color get lightColor => widget.color.applyAlpha(0.85);

  Color get lighterColor => widget.color.applyAlpha(0.60);

  void setSelectedDay(
    DateTime? newSelectedDay, [
    DateTime? newSelectedEnd,
  ]) {
    final newRange = newSelectedDay == null
        ? null
        : DateTimeRange(
            start: newSelectedDay.startOfDay,
            end: newSelectedEnd ?? newSelectedDay.endOfDay,
          );
    setState(() {
      selectedDay = newSelectedDay ?? selectedDay;
      selectedRange = newRange ?? selectedRange;
      if (widget.onChange != null) {
        widget.onChange!(newRange);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final header = CalendarHeader(
      focusedDay: focusedDay,
      onLeftChevronTap: () => setState(
        () => focusedDay = widget.weekFormat
            ? _previousWeek(focusedDay)
            : _previousMonth(focusedDay),
      ),
      onRightChevronTap: () => setState(
        () => focusedDay = widget.weekFormat
            ? _nextWeek(focusedDay)
            : _nextMonth(focusedDay),
      ),
      onTodayButtonTap: () => setState(() => focusedDay = DateTime.now()),
      titleStyle: widget.titleStyle,
      iconColor: widget.iconColor,
      locale: widget.locale,
      twoRowHeader: widget.twoRowHeader,
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.headerWrapper != null ? widget.headerWrapper!(header) : header,
          TableCalendar(
            focusedDay: focusedDay,
            selectedDayPredicate: (date) => isSameDay(selectedDay, date),
            firstDay: kFirstDay,
            lastDay: kLastDay,
            calendarFormat: calendarFormat,
            headerVisible: false,
            locale: widget.locale,
            eventLoader: widget.eventLoader,
            rowHeight: widget.rowHeight ?? MediaQuery.sizeOf(context).width / 7,
            calendarBuilders: CalendarBuilders(
                    markerBuilder: widget.animateDays && widget.markerBuilder != null
                        ? (context, day, events) => _AnimatedMarker(
                              key: ValueKey('m_${focusedDay.month}_${day.day}'),
                              day: day,
                              focusedDay: focusedDay,
                              baseDelayMs: widget.animationBaseDelayMs,
                              rowStaggerMs: widget.rowStaggerMs,
                              child: widget.markerBuilder!(context, day, events),
                            )
                        : widget.markerBuilder,
                    dowBuilder: widget.animateDays
                        ? (context, day) => _AnimatedDowCell(
                              key: ValueKey('dow_${day.weekday}'),
                              day: day,
                              baseDelayMs: (widget.animationBaseDelayMs - widget.rowStaggerMs).clamp(0, 9999),
                              style: const TextStyle(color: Color(0xFF616161))
                                  .merge(widget.dayOfWeekStyle),
                            )
                        : null,
                    defaultBuilder: widget.animateDays
                        ? (context, day, focused) => _AnimatedDayCell(
                              key: ValueKey('d_${focused.month}_${day.day}'),
                              day: day,
                              focusedDay: focused,
                              isSelected: false,
                              isToday: false,
                              isOutside: false,
                              style: widget.dateStyle,
                              color: color,
                              lighterColor: lighterColor,
                              baseDelayMs: widget.animationBaseDelayMs,
                              rowStaggerMs: widget.rowStaggerMs,
                            )
                        : null,
                    todayBuilder: widget.animateDays
                        ? (context, day, focused) => _AnimatedDayCell(
                              key: ValueKey('t_${focused.month}_${day.day}'),
                              day: day,
                              focusedDay: focused,
                              isSelected: false,
                              isToday: true,
                              isOutside: false,
                              style: widget.selectedDateStyle,
                              color: color,
                              lighterColor: lighterColor,
                              baseDelayMs: widget.animationBaseDelayMs,
                              rowStaggerMs: widget.rowStaggerMs,
                            )
                        : null,
                    selectedBuilder: widget.animateDays
                        ? (context, day, focused) => _AnimatedDayCell(
                              key: ValueKey('s_${focused.month}_${day.day}'),
                              day: day,
                              focusedDay: focused,
                              isSelected: true,
                              isToday: false,
                              isOutside: false,
                              style: widget.selectedDateStyle,
                              color: color,
                              lighterColor: lighterColor,
                              baseDelayMs: widget.animationBaseDelayMs,
                              rowStaggerMs: widget.rowStaggerMs,
                            )
                        : null,
                    outsideBuilder: widget.animateDays
                        ? (context, day, focused) => _AnimatedDayCell(
                              key: ValueKey('o_${focused.month}_${day.day}'),
                              day: day,
                              focusedDay: focused,
                              isSelected: false,
                              isToday: false,
                              isOutside: true,
                              style: widget.inactiveDateStyle,
                              color: color,
                              lighterColor: lighterColor,
                              baseDelayMs: widget.animationBaseDelayMs,
                              rowStaggerMs: widget.rowStaggerMs,
                            )
                        : null,
                  ),
            calendarStyle: CalendarStyle(
              defaultTextStyle:
                  widget.dateStyle ?? const TextStyle(color: Color(0xFF5A5A5A)),
              weekendTextStyle:
                  widget.dateStyle ?? const TextStyle(color: Color(0xFF5A5A5A)),
              holidayTextStyle:
                  widget.dateStyle ?? const TextStyle(color: Color(0xFF5C6BC0)),
              selectedTextStyle:
                  const TextStyle(color: Color(0xFFFAFAFA), fontSize: 16.0)
                      .merge(widget.selectedDateStyle),
              todayTextStyle:
                  const TextStyle(color: Color(0xFFFAFAFA), fontSize: 16.0)
                      .merge(widget.selectedDateStyle),
              outsideTextStyle: const TextStyle(color: Color(0xFF9E9E9E))
                  .merge(widget.inactiveDateStyle),
              selectedDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.0),
              ),
              todayDecoration: BoxDecoration(
                color: lighterColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: lightColor,
                shape: BoxShape.circle,
              ),
              markersMaxCount: widget.markerBuilder != null ? 0 : 1,
              canMarkersOverflow: false,
            ),
            availableGestures: AvailableGestures.horizontalSwipe,
            startingDayOfWeek: startingDayOfWeek,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: const TextStyle(color: Color(0xFF616161))
                  .merge(widget.dayOfWeekStyle),
              weekendStyle: const TextStyle(color: Color(0xFF616161))
                  .merge(widget.dayOfWeekStyle),
            ),
            onPageChanged: (focused) {
              if (focusedDay.startOfDay != focused.startOfDay) {
                setState(() => focusedDay = focused);
              }
            },
            onDaySelected: (newSelectedDay, focused) {
              if (!isSameDay(selectedDay, newSelectedDay)) {
                setSelectedDay(newSelectedDay);
                if (focusedDay.startOfDay != focused.startOfDay) {
                  setState(() => focusedDay = focused);
                }
              }
            },
          ),
        ],
      );
  }
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.onTodayButtonTap,
    this.iconColor,
    this.titleStyle,
    this.locale,
    this.twoRowHeader = false,
  });

  final DateTime focusedDay;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final VoidCallback onTodayButtonTap;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final String? locale;
  final bool twoRowHeader;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(),
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: twoRowHeader ? _buildTwoRowHeader() : _buildOneRowHeader(),
      );

  Widget _buildTwoRowHeader() => Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(width: 16),
              _buildDateWidget(),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildCustomIconButtons(),
          ),
        ],
      );

  Widget _buildOneRowHeader() => Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const SizedBox(width: 16),
          _buildDateWidget(),
          ..._buildCustomIconButtons(),
        ],
      );

  Widget _buildDateWidget() => Expanded(
        child: Text(
          DateFormat.yMMMM(locale).format(focusedDay),
          style: const TextStyle(fontSize: 17).merge(titleStyle),
        ),
      );

  List<Widget> _buildCustomIconButtons() => <Widget>[
        CustomIconButton(
          icon: Icon(Icons.calendar_today, color: iconColor),
          onTap: onTodayButtonTap,
        ),
        CustomIconButton(
          icon: Icon(Icons.chevron_left, color: iconColor),
          onTap: onLeftChevronTap,
        ),
        CustomIconButton(
          icon: Icon(Icons.chevron_right, color: iconColor),
          onTap: onRightChevronTap,
        ),
      ];
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
    this.padding = const EdgeInsets.all(10),
  });

  final Icon icon;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: padding,
            child: Icon(
              icon.icon,
              color: icon.color,
              size: icon.size,
            ),
          ),
        ),
      );
}

/// Animated day-of-week label that fades in as a row.
class _AnimatedDowCell extends StatefulWidget {
  final DateTime day;
  final int baseDelayMs;
  final TextStyle? style;

  const _AnimatedDowCell({
    super.key,
    required this.day,
    this.baseDelayMs = 300,
    this.style,
  });

  @override
  State<_AnimatedDowCell> createState() => _AnimatedDowCellState();
}

class _AnimatedDowCellState extends State<_AnimatedDowCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    // Subtle left-to-right stagger within the dow row
    final col = (widget.day.weekday % 7); // Sunday=0
    final delay = widget.baseDelayMs + (col * 10);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = DateFormat.E().format(widget.day).substring(0, 2);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Text(
          text,
          style: widget.style ?? const TextStyle(color: Color(0xFF616161)),
        ),
      ),
    );
  }
}

/// Animated day cell that fades+scales in with a stagger based on grid position.
class _AnimatedDayCell extends StatefulWidget {
  final DateTime day;
  final DateTime focusedDay;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final TextStyle? style;
  final Color color;
  final Color lighterColor;
  final int baseDelayMs;
  final int rowStaggerMs;

  const _AnimatedDayCell({
    super.key,
    required this.day,
    required this.focusedDay,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    this.style,
    required this.color,
    required this.lighterColor,
    this.baseDelayMs = 100,
    this.rowStaggerMs = 120,
  });

  @override
  State<_AnimatedDayCell> createState() => _AnimatedDayCellState();
}

class _AnimatedDayCellState extends State<_AnimatedDayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Stagger by ROW so each row of 7 days appears together, rippling top to bottom.
    final firstOfMonth = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
    final firstVisibleDay = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday % 7));
    final gridPosition = widget.day.difference(firstVisibleDay).inDays.clamp(0, 41);
    final row = gridPosition ~/ 7;
    final col = gridPosition % 7;
    // Row-based stagger + subtle left-to-right within each row
    final delay = widget.baseDelayMs + (row * widget.rowStaggerMs) + (col * 8);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Text color and style
    final TextStyle textStyle;
    if (widget.isOutside) {
      textStyle = const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14.0)
          .merge(widget.style);
    } else if (widget.isSelected || widget.isToday) {
      textStyle = const TextStyle(color: Color(0xFFFAFAFA), fontSize: 16.0)
          .merge(widget.style);
    } else {
      textStyle = const TextStyle(color: Color(0xFF5A5A5A), fontSize: 14.0)
          .merge(widget.style);
    }

    // Decoration
    BoxDecoration? decoration;
    if (widget.isSelected) {
      decoration = BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: widget.color, width: 2.0),
      );
    } else if (widget.isToday) {
      decoration = BoxDecoration(
        color: widget.lighterColor,
        shape: BoxShape.circle,
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(
              '${widget.day.day}',
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}

DateTime _previousWeek(DateTime week) {
  return week.subtract(const Duration(days: 7));
}

/// Animated marker wrapper — fades in with the same timing as the day cell.
class _AnimatedMarker extends StatefulWidget {
  final DateTime day;
  final DateTime focusedDay;
  final int baseDelayMs;
  final int rowStaggerMs;
  final Widget child;

  const _AnimatedMarker({
    super.key,
    required this.day,
    required this.focusedDay,
    required this.baseDelayMs,
    required this.rowStaggerMs,
    required this.child,
  });

  @override
  State<_AnimatedMarker> createState() => _AnimatedMarkerState();
}

class _AnimatedMarkerState extends State<_AnimatedMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Same row-based delay calculation as _AnimatedDayCell
    final firstOfMonth = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
    final firstVisibleDay = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday % 7));
    final gridPosition = widget.day.difference(firstVisibleDay).inDays.clamp(0, 41);
    final row = gridPosition ~/ 7;
    final col = gridPosition % 7;
    final delay = widget.baseDelayMs + (row * widget.rowStaggerMs) + (col * 8);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

DateTime _nextWeek(DateTime week) {
  return week.add(const Duration(days: 7));
}

DateTime _previousMonth(DateTime month) {
  if (month.month == 1) {
    return DateTime(month.year - 1, 12);
  } else {
    return DateTime(month.year, month.month - 1);
  }
}

DateTime _nextMonth(DateTime month) {
  if (month.month == 12) {
    return DateTime(month.year + 1, 1);
  } else {
    return DateTime(month.year, month.month + 1);
  }
}
