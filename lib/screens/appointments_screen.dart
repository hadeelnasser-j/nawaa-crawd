import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';
import '../widgets/app_top_bar.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final titleCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  DateTime? selectedDateTime;
  int remindBeforeMinutes = 10;

  @override
  void dispose() {
    titleCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  // (اختياري) إذا احتجتيه لاحقًا
  Color dotColor(AppointmentItem a) {
    if (a.done) return Colors.white24;
    final diff = a.dateTime.difference(DateTime.now());
    if (diff.isNegative) return AppState.highCrowdColor;
    if (diff.inHours < 24) return AppState.mediumCrowdColor;
    return AppState.lowCrowdColor;
  }

  String statusText(AppointmentItem a) {
    if (a.done) return context.getString('done');
    final diff = a.dateTime.difference(DateTime.now());
    if (diff.isNegative) return context.getString('expired');
    if (diff.inHours < 24) return context.getString('soon');
    return context.getString('upcoming');
  }

  Color statusColor(AppointmentItem a) {
    if (a.done) return Colors.white38;
    final diff = a.dateTime.difference(DateTime.now());
    if (diff.isNegative) return AppState.highCrowdColor;
    if (diff.inHours < 24) return AppState.mediumCrowdColor;
    return AppState.lowCrowdColor;
  }

  String formatDate(DateTime d) {
    final locale = context.read<AppState>().locale;
    return intl.DateFormat('EEE d MMM', locale).format(d);
  }

  String formatTime(DateTime d) {
    final locale = context.read<AppState>().locale;
    return intl.DateFormat('HH:mm', locale).format(d);
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textDirection: context.textDirection),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  void openAddSheet() {
    final now = DateTime.now().add(const Duration(minutes: 30));
    titleCtrl.clear();
    notesCtrl.clear();
    selectedDateTime = now;
    remindBeforeMinutes = 10;
    openSheet(isEdit: false);
  }

  void openEditSheet(AppointmentItem a) {
    titleCtrl.text = a.title;
    notesCtrl.text = a.notes ?? '';
    selectedDateTime = a.dateTime;
    remindBeforeMinutes = a.remindBeforeMinutes;
    openSheet(isEdit: true, existing: a);
  }

  void openSheet({required bool isEdit, AppointmentItem? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Directionality(
                textDirection: context.textDirection,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.getString(
                          isEdit ? 'editAppointment' : 'newAppointment'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                              ) ??
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: _input(context.getString('titleRequired')),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      decoration: _input(context.getString('notesOptional')),
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _picker(
                            label: context.getString('date'),
                            value: selectedDateTime == null
                                ? context.getString('choose')
                                : formatDate(selectedDateTime!),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDateTime ?? DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2100),
                              );
                              if (d == null) return;

                              setModalState(() {
                                selectedDateTime = DateTime(
                                  d.year,
                                  d.month,
                                  d.day,
                                  selectedDateTime?.hour ?? 12,
                                  selectedDateTime?.minute ?? 0,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _picker(
                            label: context.getString('time'),
                            value: selectedDateTime == null
                                ? context.getString('choose')
                                : formatTime(selectedDateTime!),
                            onTap: () async {
                              final t = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay.fromDateTime(
                                  selectedDateTime ?? DateTime.now(),
                                ),
                              );
                              if (t == null) return;

                              setModalState(() {
                                final d = selectedDateTime ?? DateTime.now();
                                selectedDateTime = DateTime(
                                  d.year,
                                  d.month,
                                  d.day,
                                  t.hour,
                                  t.minute,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [10, 30, 60, 1440].map((m) {
                        final selected = remindBeforeMinutes == m;
                        return ChoiceChip(
                          label: Text(
                            m == 1440
                                ? context.getString('beforeDay')
                                : context.formatString(
                                    'beforeMinutes',
                                    {'minutes': m.toString()},
                                  ),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setModalState(() => remindBeforeMinutes = m);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty ||
                            selectedDateTime == null) {
                          toast(context.getString('appointmentRequired'));
                          return;
                        }

                        final appState = ctx.read<AppState>();

                        if (isEdit && existing != null) {
                          appState.updateAppointment(
                            existing.copyWith(
                              title: titleCtrl.text.trim(),
                              notes: notesCtrl.text.trim(),
                              dateTime: selectedDateTime!,
                              remindBeforeMinutes: remindBeforeMinutes,
                            ),
                          );
                          toast(context.getString('appointmentUpdated'));
                        } else {
                          appState.addAppointment(
                            AppointmentItem(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              title: titleCtrl.text.trim(),
                              notes: notesCtrl.text.trim(),
                              dateTime: selectedDateTime!,
                              remindBeforeMinutes: remindBeforeMinutes,
                              done: false,
                            ),
                          );
                          toast(context.getString('appointmentSaved'));
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        context.getString(
                          isEdit ? 'saveChanges' : 'saveAppointment',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final appts = appState.upcomingAppointments;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Directionality(
          textDirection: context.textDirection,
          child: Column(
            children: [
              const AppTopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.getString('appointments'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 22,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            context.getString('appointmentsSubtitle'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: openAddSheet,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 112),
                  children: [
                    if (appts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 64),
                          child: Text(
                            context.getString('noAppointments'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ...appts.map(
                        (a) => Card(
                          color: Theme.of(context).cardColor,
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                a.done
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: a.done
                                    ? AppState.lowCrowdColor
                                    : Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withValues(alpha: 0.38),
                              ),
                              onPressed: () =>
                                  appState.toggleAppointmentDone(a.id),
                            ),
                            title: Text(
                              a.title,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              '${formatDate(a.dateTime)} • ${formatTime(a.dateTime)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.54),
                                  ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  statusText(a),
                                  style: TextStyle(color: statusColor(a)),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => openEditSheet(a),
                                      child: Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Theme.of(context)
                                            .iconTheme
                                            .color
                                            ?.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<AppState>()
                                            .deleteAppointment(a.id);
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _picker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
