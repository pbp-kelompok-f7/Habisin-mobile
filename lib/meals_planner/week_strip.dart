import 'package:flutter/material.dart';

import 'planner_style.dart';

const dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

DateTime dayOffset(DateTime date, int offset) =>
    DateTime(date.year, date.month, date.day + offset);

String shortDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.monday,
    required this.day,
    required this.onDay,
    required this.onWeek,
  });

  final DateTime monday;
  final int day;
  final ValueChanged<int> onDay;
  final ValueChanged<int> onWeek;

  @override
  Widget build(BuildContext context) {
    final sunday = dayOffset(monday, 6);
    final start = monday.year == sunday.year ? shortDate(monday) : '${shortDate(monday)} ${monday.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.date_range_rounded, color: plannerGreen, size: 21),
          const SizedBox(width: 8),
          Expanded(child: Text('$start – ${shortDate(sunday)} ${sunday.year}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: plannerInk))),
          IconButton(tooltip: 'Minggu sebelumnya', onPressed: () => onWeek(-1), icon: const Icon(Icons.chevron_left)),
          IconButton(tooltip: 'Minggu berikutnya', onPressed: () => onWeek(1), icon: const Icon(Icons.chevron_right)),
        ]),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, bounds) {
          final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final cellWidth = ((bounds.maxWidth - 36) / 7).clamp(46.0 * textScale, double.infinity);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (int index = 0; index < 7; index++) ...[
                if (index > 0) const SizedBox(width: 6),
                Builder(builder: (context) {
                  final date = dayOffset(monday, index);
                  final selected = day == index;
                  final today = DateUtils.isSameDay(date, DateTime.now());
                  return Semantics(
                    selected: selected,
                    label: '${dayNames[index]}, ${shortDate(date)}${today ? ", hari ini" : ""}',
                    button: true,
                    child: ExcludeSemantics(child: Material(
                      color: selected ? plannerGreen : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: selected ? plannerGreen : plannerLine)),
                      child: InkWell(onTap: () => onDay(index), borderRadius: BorderRadius.circular(16),
                        child: SizedBox(width: cellWidth, child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Column(children: [
                            Text(dayNames[index].substring(0, 3), style: TextStyle(fontSize: 13, color: selected ? Colors.white : plannerMuted)),
                            Text('${date.day}', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: selected ? Colors.white : plannerInk)),
                            Container(height: 4, width: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: today ? (selected ? plannerPeach : plannerGreen) : Colors.transparent)),
                          ]),
                        )),
                      ),
                    )),
                  );
                }),
              ],
            ]),
          );
        }),
      ],
    );
  }
}
