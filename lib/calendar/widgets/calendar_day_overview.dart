import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jambu/calendar/bloc/calendar_bloc.dart';
import 'package:jambu/calendar/model/model.dart';
import 'package:jambu/extension/extension.dart';

class CalendarDayOverview extends StatelessWidget {
  const CalendarDayOverview({
    required this.day,
    required this.tags,
    this.isBestChoice = false,
    super.key,
  });

  final CalendarDay day;
  final List<String> tags;
  final bool isBestChoice;

  @override
  Widget build(BuildContext context) {
    final weekday = day.date.weekdayString.characters.take(2).string;
    final formattedDate = DateFormat('dd').format(day.date);
    final isUserAttending = day.isUserAttending;
    final bgColor = isUserAttending
        ? AppColors.green.withOpacity(0.2)
        : isBestChoice
            ? AppColors.pink.withOpacity(0.2)
            : Colors.transparent;
    var reason = day.reason;
    if (day.isHoliday) {
      reason = '🏖️ $reason';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: bgColor,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$weekday $formattedDate',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.outerSpaceGrey,
                    ),
              ),
              if (reason != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Tooltip(
                    message: reason,
                    child: const Icon(Icons.info, size: 17),
                  ),
                )
            ],
          ),
          Text(
            isBestChoice ? 'Optimaler Tag' : '',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.outerSpaceGrey,
                ),
          ),
          const SizedBox(height: 25),
          _CheckmarkButton(
            isSelected: isUserAttending,
            onTap: (bool value) {
              context.read<CalendarBloc>().add(
                    CalendarAttendanceUpdate(
                      date: day.date.midnight,
                      isAttending: value,
                      reason: day.reason,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _CheckmarkButton extends StatelessWidget {
  const _CheckmarkButton({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final void Function(bool) onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? AppColors.white : AppColors.platinumGrey;
    final bgColor = isSelected ? AppColors.green : AppColors.seasaltGrey;
    final borderColor = isSelected ? AppColors.green : AppColors.platinumGrey;

    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(
          side: BorderSide(
            width: 3,
            color: borderColor,
          ),
        ),
        onTap: () => onTap(!isSelected),
        child: Ink(
          width: 55,
          height: 55,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Icon(
              Icons.check,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
