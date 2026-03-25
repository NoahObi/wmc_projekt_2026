import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

import 'subscription_provider.dart'; 

class NotificationState {
  final bool enabled;
  final String reminderTime;

  NotificationState({required this.enabled, required this.reminderTime});
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    _loadSettings();
    
    // hören auf Änderungen bei den Abos.
    ref.listen(subscriptionListProvider, (previous, next) {
      if (next.hasValue) {
        _rescheduleAll();
      }
    });

    return NotificationState(enabled: true, reminderTime: 'reminder_1');
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notifications') ?? true;

    String time = prefs.getString('reminder_time') ?? 'reminder_1';

    if (time == 'Am selben Tag') {time = 'reminder_0';}
    else if (time == '1 Tag vorher') {time = 'reminder_1';}
    else if (time == '3 Tage vorher') {time = 'reminder_3';}
    else if (time == '1 Woche vorher') {time = 'reminder_7';}
    
    if (!['reminder_0', 'reminder_1', 'reminder_3', 'reminder_7'].contains(time)) {
      time = 'reminder_1';
    }

    await prefs.setString('reminder_time', time);

    state = NotificationState(enabled: isEnabled, reminderTime: time);
    
    if (isEnabled) {
      _rescheduleAll();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', enabled);
    
    state = NotificationState(enabled: enabled, reminderTime: state.reminderTime);
    
    if (enabled) {
      await _rescheduleAll(); 
      await NotificationService().showTestNotification(); 
    } else {
      await NotificationService().cancelAllNotifications(); 
    }
  }

  Future<void> setReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminder_time', time);
    
    state = NotificationState(enabled: state.enabled, reminderTime: time);
    
    if (state.enabled) {
      await _rescheduleAll();
    }
  }

  Future<void> _rescheduleAll() async {
    await NotificationService().cancelAllNotifications();
    
    if (!state.enabled) return; 

    final subsAsync = ref.read(subscriptionListProvider);
    
    final subscriptions = subsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    
    if (subscriptions == null || subscriptions.isEmpty) return;

    int daysToSubtract = 0;
    if (state.reminderTime == 'reminder_1') {daysToSubtract = 1;}
    else if (state.reminderTime == 'reminder_3') {daysToSubtract = 3;}
    else if (state.reminderTime == 'reminder_7') {daysToSubtract = 7;}

    final now = DateTime.now();
    int notificationId = 100; //  damit der Test nicht versehentlich gelöscht wird

    for (var sub in subscriptions) {
      DateTime nextPayment = sub.startDate;
      
      // Berechne das NÄCHSTE Zahlungsdatum 
      while (nextPayment.isBefore(now)) {
        if (sub.billingInterval.toLowerCase() == 'yearly') {
          nextPayment = DateTime(nextPayment.year + 1, nextPayment.month, nextPayment.day);
        } else {
          nextPayment = DateTime(nextPayment.year, nextPayment.month + 1, nextPayment.day);
        }
      }

      // Erinnerungsdatum berechnen & Zeit fix auf 10:00 Uhr morgens stellen
      DateTime reminderDate = nextPayment.subtract(Duration(days: daysToSubtract));
      reminderDate = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 10, 0);

      if (reminderDate.isAfter(now)) {
        await NotificationService().scheduleNotification(
          id: notificationId++,
          title: 'Abo-Erinnerung: ${sub.name}',
          body: 'Deine Zahlung über ${sub.price.toStringAsFixed(2)} steht am ${nextPayment.day.toString().padLeft(2, '0')}.${nextPayment.month.toString().padLeft(2, '0')}.${nextPayment.year} an.',
          scheduledDate: reminderDate,
        );
      }
    }
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});