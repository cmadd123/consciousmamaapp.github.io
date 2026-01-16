import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// A custom date/time picker that matches the app's visual style.
/// Uses Material-style wheel pickers with the app's theme colors.
class CustomDateTimePicker extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final bool showTime;
  final String title;
  final void Function(DateTime) onDateTimeChanged;

  const CustomDateTimePicker({
    super.key,
    required this.initialDateTime,
    this.minimumDate,
    this.maximumDate,
    this.showTime = true,
    this.title = 'Select Date & Time',
    required this.onDateTimeChanged,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedYear;
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isPM;

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _ampmController;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialDateTime.month;
    _selectedDay = widget.initialDateTime.day;
    _selectedYear = widget.initialDateTime.year;

    int hour24 = widget.initialDateTime.hour;
    _isPM = hour24 >= 12;
    _selectedHour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    _selectedMinute = widget.initialDateTime.minute;

    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _yearController = FixedExtentScrollController(initialItem: _selectedYear - _startYear);
    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _ampmController = FixedExtentScrollController(initialItem: _isPM ? 1 : 0);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    super.dispose();
  }

  int get _startYear => widget.minimumDate?.year ?? 2020;
  int get _endYear => widget.maximumDate?.year ?? 2050;

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _updateDateTime() {
    int hour24 = _selectedHour;
    if (_isPM && _selectedHour != 12) {
      hour24 = _selectedHour + 12;
    } else if (!_isPM && _selectedHour == 12) {
      hour24 = 0;
    }

    final newDateTime = DateTime(
      _selectedYear,
      _selectedMonth,
      _selectedDay,
      hour24,
      _selectedMinute,
    );
    widget.onDateTimeChanged(newDateTime);
  }

  Widget _buildWheelPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) itemBuilder,
    required void Function(int) onSelectedItemChanged,
    double width = 80,
    bool centerText = true,
  }) {
    return SizedBox(
      width: width,
      height: 200,
      child: Stack(
        children: [
          // Selection highlight
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Wheel
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final isSelected = controller.selectedItem == index;
                return Center(
                  child: Text(
                    itemBuilder(index),
                    textAlign: centerText ? TextAlign.center : TextAlign.left,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: isSelected ? 20 : 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInCurrentMonth = _daysInMonth(_selectedYear, _selectedMonth);

    // Ensure selected day is valid for current month
    if (_selectedDay > daysInCurrentMonth) {
      _selectedDay = daysInCurrentMonth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dayController.jumpToItem(_selectedDay - 1);
      });
    }

    return Container(
      height: widget.showTime ? 400 : 340,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  widget.title,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _updateDateTime();
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          // Date section label
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'Date',
              style: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'Andika New Basic',
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ),
          // Date wheels
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Month wheel
                _buildWheelPicker(
                  controller: _monthController,
                  itemCount: 12,
                  width: 110,
                  itemBuilder: (index) => _months[index],
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedMonth = index + 1;
                      // Adjust day if needed
                      final maxDays = _daysInMonth(_selectedYear, _selectedMonth);
                      if (_selectedDay > maxDays) {
                        _selectedDay = maxDays;
                        _dayController.jumpToItem(_selectedDay - 1);
                      }
                    });
                  },
                ),
                // Day wheel
                _buildWheelPicker(
                  controller: _dayController,
                  itemCount: daysInCurrentMonth,
                  width: 60,
                  itemBuilder: (index) => '${index + 1}',
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedDay = index + 1;
                    });
                  },
                ),
                // Year wheel
                _buildWheelPicker(
                  controller: _yearController,
                  itemCount: _endYear - _startYear + 1,
                  width: 80,
                  itemBuilder: (index) => '${_startYear + index}',
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedYear = _startYear + index;
                      // Adjust day if needed (for leap years)
                      final maxDays = _daysInMonth(_selectedYear, _selectedMonth);
                      if (_selectedDay > maxDays) {
                        _selectedDay = maxDays;
                        _dayController.jumpToItem(_selectedDay - 1);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          // Time section
          if (widget.showTime) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                'Time',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            // Time wheels
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour wheel
                  _buildWheelPicker(
                    controller: _hourController,
                    itemCount: 12,
                    width: 60,
                    itemBuilder: (index) => '${index + 1}',
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHour = index + 1;
                      });
                    },
                  ),
                  // Colon separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      ':',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  // Minute wheel
                  _buildWheelPicker(
                    controller: _minuteController,
                    itemCount: 60,
                    width: 60,
                    itemBuilder: (index) => index.toString().padLeft(2, '0'),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMinute = index;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // AM/PM wheel
                  _buildWheelPicker(
                    controller: _ampmController,
                    itemCount: 2,
                    width: 60,
                    itemBuilder: (index) => index == 0 ? 'AM' : 'PM',
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _isPM = index == 1;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows a custom date/time picker bottom sheet.
/// Returns the selected DateTime, or null if cancelled.
Future<DateTime?> showCustomDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  DateTime? minimumDate,
  DateTime? maximumDate,
  bool showTime = true,
  String title = 'Select Date & Time',
}) async {
  DateTime selectedDateTime = initialDateTime;

  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return CustomDateTimePicker(
        initialDateTime: initialDateTime,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        showTime: showTime,
        title: title,
        onDateTimeChanged: (dateTime) {
          selectedDateTime = dateTime;
        },
      );
    },
  );

  return result == true ? selectedDateTime : null;
}
