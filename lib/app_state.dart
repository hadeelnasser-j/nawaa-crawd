import 'package:flutter/material.dart';

/* ===== Screens ===== */
enum AppScreen {
  login,
  userLogin,
  companyAccess,
  terms,
  premium,
  payment,
  onboarding,
  home,
  explore,
  placeDetails,
  aiPrediction,
  notifications,
  appointments,
}

/* ===== Tabs ===== */
enum AppTab {
  home,
  explore,
  appointments,
  notifications,
}

/* ===== Models ===== */
enum CrowdLevel { low, medium, high }

class HourlyPrediction {
  final String hour;
  final CrowdLevel level;
  final int value;

  HourlyPrediction({
    required this.hour,
    required this.level,
    required this.value,
  });
}

class Place {
  final String id;
  final String nameAr;
  final String nameEn;
  final String addressAr;
  final String addressEn;
  final String category;
  final double rating;
  final int waitTimeMin;
  final int waitTimeMax;
  final String bestTimeToVisitAr;
  final String bestTimeToVisitEn;
  final bool isNearby;
  final List<HourlyPrediction> predictions;

  Place({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.addressAr,
    required this.addressEn,
    required this.category,
    required this.rating,
    required this.waitTimeMin,
    required this.waitTimeMax,
    required this.bestTimeToVisitAr,
    required this.bestTimeToVisitEn,
    required this.isNearby,
    required this.predictions,
  });

  String get name => nameAr;
  String get address => addressAr;
  String get waitTime => '$waitTimeMin-$waitTimeMax mins';
  String get bestTimeToVisit => bestTimeToVisitEn;
  double get averageWaitTime => (waitTimeMin + waitTimeMax) / 2;

  CrowdLevel get crowdLevel {
    if (averageWaitTime < 15) return CrowdLevel.low;
    if (averageWaitTime <= 30) return CrowdLevel.medium;
    return CrowdLevel.high;
  }

  String localizedName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String localizedAddress(String locale) =>
      locale == 'ar' ? addressAr : addressEn;
  String localizedWaitTime(String locale) =>
      locale == 'ar' ? '$waitTimeMin-$waitTimeMax دقيقة' : waitTime;
  String localizedBestTimeToVisit(String locale) =>
      locale == 'ar' ? bestTimeToVisitAr : bestTimeToVisitEn;
}

/* ===== Notifications Models (Central) ===== */
enum NotificationType { alert, success, info }

class AppNotification {
  final String id;
  final String placeId;
  final String placeName;
  final String message;
  final String time;
  final NotificationType type;
  bool read;

  AppNotification({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.message,
    required this.time,
    required this.type,
    this.read = false,
  });
}

/* ===== Appointments Models (NEW) ===== */
class AppointmentItem {
  final String id;
  final String title;
  final String? notes;
  final DateTime dateTime;
  final int remindBeforeMinutes; // e.g. 10, 30, 60, 1440
  final bool done;

  AppointmentItem({
    required this.id,
    required this.title,
    this.notes,
    required this.dateTime,
    required this.remindBeforeMinutes,
    required this.done,
  });

  AppointmentItem copyWith({
    String? title,
    String? notes,
    DateTime? dateTime,
    int? remindBeforeMinutes,
    bool? done,
  }) {
    return AppointmentItem(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dateTime: dateTime ?? this.dateTime,
      remindBeforeMinutes: remindBeforeMinutes ?? this.remindBeforeMinutes,
      done: done ?? this.done,
    );
  }
}

/* ===== AppState ===== */
class AppState extends ChangeNotifier {
  /* ===== Localization & Theme ===== */
  String _locale = 'ar'; // Default to Arabic
  bool _isDarkMode = true; // Default to Dark Mode
  bool _isPremiumUser = false;
  String _userName = 'همس';
  String _userEmail = 'hams@example.com';
  String _userLocation = 'جدة';

  String get locale => _locale;
  bool get isDarkMode => _isDarkMode;
  bool get isPremiumUser => _isPremiumUser;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userLocation => _userLocation;

  void setLocale(String newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool dark) {
    if (_isDarkMode != dark) {
      _isDarkMode = dark;
      notifyListeners();
    }
  }

  void subscribeToPremium() {
    _isPremiumUser = true;
    goBackFromPremium();
  }

  void cancelPremium() {
    _isPremiumUser = false;
    notifyListeners();
  }

  void openPayment() {
    goTo(AppScreen.payment);
  }

  void completePayment() {
    _isPremiumUser = true;
    goTo(AppScreen.premium);
  }

  void setUserName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _userName = trimmed;
    notifyListeners();
  }

  void setUserEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _userEmail = trimmed;
    notifyListeners();
  }

  void setUserLocation(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _userLocation = trimmed;
    notifyListeners();
  }

  /* ===== Navigation ===== */
  AppScreen currentScreen = AppScreen.login;
  AppScreen? _screenBeforePremium;

  /* ===== Selected Place ===== */
  Place? selectedPlace;

  static const Color lowCrowdColor = Color(0xFF22C55E);
  static const Color mediumCrowdColor = Color(0xFFEAB308);
  static const Color highCrowdColor = Color(0xFFE44E02);

  /* ===== Places ===== */
  late final List<Place> places = [
    Place(
      id: 'starbucks-salamah',
      nameAr: 'Starbucks',
      nameEn: 'Starbucks',
      addressAr: 'حي السلامة، بالقرب من جامعة جدة - الفيصلية',
      addressEn: 'Al Salamah, near University of Jeddah - Al Faisaliyah',
      category: 'cafe',
      rating: 4.5,
      waitTimeMin: 10,
      waitTimeMax: 15,
      bestTimeToVisitAr: '9-11 صباحًا',
      bestTimeToVisitEn: '9-11 AM',
      isNearby: true,
      predictions: _mockPredictions(base: CrowdLevel.low),
    ),
    Place(
      id: 'costa-salamah',
      nameAr: 'Costa Coffee ',
      nameEn: 'Costa Coffee ',
      addressAr: 'حي السلامة',
      addressEn: 'Al Salamah',
      category: 'cafe',
      rating: 4.2,
      waitTimeMin: 8,
      waitTimeMax: 12,
      bestTimeToVisitAr: '10 صباحًا - 12 ظهرًا',
      bestTimeToVisitEn: '10 AM - 12 PM',
      isNearby: true,
      predictions: _mockPredictions(base: CrowdLevel.low),
    ),
    Place(
      id: 'aziz-mall',
      nameAr: 'عزيز مول',
      nameEn: 'Aziz Mall',
      addressAr: 'حي الفيصلة',
      addressEn: 'Al Faisaliyah',
      category: 'mall',
      rating: 4.1,
      waitTimeMin: 20,
      waitTimeMax: 30,
      bestTimeToVisitAr: '11 صباحًا - 2 ظهرًا',
      bestTimeToVisitEn: '11 AM - 2 PM',
      isNearby: true,
      predictions: _mockPredictions(base: CrowdLevel.medium),
    ),
    Place(
      id: 'albaik-faisaliyah',
      nameAr: 'مطعم البيك',
      nameEn: 'Albaik Restaurant',
      addressAr: 'حي الفيصلية',
      addressEn: 'Al Faisaliyah',
      category: 'restaurant',
      rating: 4.6,
      waitTimeMin: 15,
      waitTimeMax: 25,
      bestTimeToVisitAr: 'قبل 12 ظهرًا',
      bestTimeToVisitEn: 'Before 12 PM',
      isNearby: true,
      predictions: _mockPredictions(base: CrowdLevel.medium),
    ),
    Place(
      id: 'king-fahd-hospital',
      nameAr: 'مستشفى الملك فهد',
      nameEn: 'King Fahd Hospital',
      addressAr: 'الفيصلية',
      addressEn: 'Al Faisaliyah',
      category: 'hospital',
      rating: 4.0,
      waitTimeMin: 25,
      waitTimeMax: 40,
      bestTimeToVisitAr: '8-10 صباحًا',
      bestTimeToVisitEn: '8-10 AM',
      isNearby: true,
      predictions: _mockPredictions(base: CrowdLevel.high),
    ),
    Place(
      id: 'starbucks-obhur-mall',
      nameAr: 'Starbucks',
      nameEn: 'Starbucks',
      addressAr: 'أبحر مول، جدة',
      addressEn: 'Obhur Mall, Jeddah',
      category: 'cafe',
      rating: 4.4,
      waitTimeMin: 8,
      waitTimeMax: 10,
      bestTimeToVisitAr: '9-11 صباحًا',
      bestTimeToVisitEn: '9-11 AM',
      isNearby: false,
      predictions: _mockPredictions(base: CrowdLevel.low),
    ),
    Place(
      id: 'costa-red-sea-mall',
      nameAr: 'Costa Coffee',
      nameEn: 'Costa Coffee',
      addressAr: 'رد سي مول، جدة',
      addressEn: 'Red Sea Mall, Jeddah',
      category: 'cafe',
      rating: 4.2,
      waitTimeMin: 25,
      waitTimeMax: 35,
      bestTimeToVisitAr: 'قبل 12 ظهرًا',
      bestTimeToVisitEn: 'Before 12 PM',
      isNearby: false,
      predictions: _mockPredictions(base: CrowdLevel.medium),
    ),
    Place(
      id: 'red-sea-mall',
      nameAr: 'رد سي مول',
      nameEn: 'Red Sea Mall',
      addressAr: 'طريق الملك عبدالعزيز، جدة',
      addressEn: 'King Abdulaziz Road, Jeddah',
      category: 'mall',
      rating: 4.5,
      waitTimeMin: 25,
      waitTimeMax: 30,
      bestTimeToVisitAr: '10 صباحًا - 1 ظهرًا',
      bestTimeToVisitEn: '10 AM - 1 PM',
      isNearby: false,
      predictions: _mockPredictions(base: CrowdLevel.medium),
    ),
    Place(
      id: 'albaik-shati',
      nameAr: 'مطعم البيك',
      nameEn: 'Albaik Restaurant (Al Shati)',
      addressAr: 'حي الشاطئ، جدة',
      addressEn: 'Al Shati, Jeddah',
      category: 'restaurant',
      rating: 4.6,
      waitTimeMin: 20,
      waitTimeMax: 35,
      bestTimeToVisitAr: 'قبل 12 ظهرًا',
      bestTimeToVisitEn: 'Before 12 PM',
      isNearby: false,
      predictions: _mockPredictions(base: CrowdLevel.medium),
    ),
    Place(
      id: 'fakeeh-hospital',
      nameAr: 'مستشفى الدكتور سليمان فقيه',
      nameEn: 'Dr. Soliman Fakeeh Hospital',
      addressAr: 'شارع فلسطين، جدة',
      addressEn: 'Palestine Street, Jeddah',
      category: 'hospital',
      rating: 4.1,
      waitTimeMin: 35,
      waitTimeMax: 50,
      bestTimeToVisitAr: '8-10 صباحًا',
      bestTimeToVisitEn: '8-10 AM',
      isNearby: false,
      predictions: _mockPredictions(base: CrowdLevel.high),
    ),
  ];

  Place get nawaaSuggestion {
    final nearbyPlaces = places.where((place) => place.isNearby).toList();
    nearbyPlaces.sort((a, b) {
      final minCompare = a.waitTimeMin.compareTo(b.waitTimeMin);
      if (minCompare != 0) return minCompare;
      return a.waitTimeMax.compareTo(b.waitTimeMax);
    });
    return nearbyPlaces.first;
  }

  List<Place> get placesByCrowd {
    final sorted = [...places];
    sorted.sort((a, b) {
      final minCompare = a.waitTimeMin.compareTo(b.waitTimeMin);
      if (minCompare != 0) return minCompare;
      return a.waitTimeMax.compareTo(b.waitTimeMax);
    });
    return sorted;
  }

  /* ===== Active Tab ===== */
  AppTab activeTab = AppTab.home;

  /* ===== Notifications (Central State) ===== */
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      placeId: 'starbucks-salamah',
      placeName: 'Starbucks',
      message: 'crowdIncreased',
      time: 'minutesAgo:5',
      type: NotificationType.alert,
      read: true,
    ),
    AppNotification(
      id: '2',
      placeId: 'costa-salamah',
      placeName: 'Costa Coffee ',
      message: 'greatTimeToVisit',
      time: 'minutesAgo:20',
      type: NotificationType.success,
      read: true,
    ),
    AppNotification(
      id: '3',
      placeId: 'aziz-mall',
      placeName: 'عزيز مول',
      message: 'crowdStable',
      time: 'hourAgo',
      type: NotificationType.info,
      read: true,
    ),
  ];

  // Keep compatibility with BottomNav badge.
  int get notificationCount => unreadNotificationsCount;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.read).length;

  void _syncNotificationCount() {}

  void addNotification(AppNotification notif) {
    _notifications.insert(0, notif);
    _syncNotificationCount();
    notifyListeners();
  }

  void addPlaceNotification({
    required Place place,
    required String message,
    required NotificationType type,
    String time = 'الآن',
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    addNotification(
      AppNotification(
        id: id,
        placeId: place.id,
        placeName: place.nameAr,
        message: message,
        time: time,
        type: type,
        read: false,
      ),
    );
  }

  void markNotificationRead(String id) {
    final i = _notifications.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _notifications[i].read = true;
    _syncNotificationCount();
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in _notifications) {
      n.read = true;
    }
    _syncNotificationCount();
    notifyListeners();
  }

  Place? findPlaceById(String id) {
    try {
      return places.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /* ===== Appointments (NEW - Central State) ===== */
  final List<AppointmentItem> _appointments = [];

  List<AppointmentItem> get appointments => List.unmodifiable(_appointments);

  /// Sorted list (nearest first). Keeps past items too, but sorted.
  List<AppointmentItem> get upcomingAppointments {
    final list = [..._appointments];
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  void addAppointment(AppointmentItem item) {
    _appointments.insert(0, item);
    notifyListeners();

    // TODO (optional): schedule local notification here
    // scheduleReminder(item);
  }

  void updateAppointment(AppointmentItem item) {
    final i = _appointments.indexWhere((a) => a.id == item.id);
    if (i == -1) return;

    _appointments[i] = item;
    notifyListeners();

    // TODO (optional): cancel & reschedule local notification here
    // cancelReminder(item.id);
    // scheduleReminder(item);
  }

  void deleteAppointment(String id) {
    _appointments.removeWhere((a) => a.id == id);
    notifyListeners();

    // TODO (optional): cancel scheduled notification here
    // cancelReminder(id);
  }

  void toggleAppointmentDone(String id) {
    final i = _appointments.indexWhere((a) => a.id == id);
    if (i == -1) return;

    final current = _appointments[i];
    _appointments[i] = current.copyWith(done: !current.done);
    notifyListeners();

    // TODO (optional): if done => cancel reminder
    // if (_appointments[i].done) cancelReminder(id);
  }

  /* ===== Navigation methods ===== */
  void goTo(AppScreen screen) {
    currentScreen = screen;

    // Keep badge synced
    _syncNotificationCount();

    notifyListeners();
  }

  void openPremium() {
    if (currentScreen != AppScreen.premium) {
      _screenBeforePremium = currentScreen;
    }
    goTo(AppScreen.premium);
  }

  void goBackFromPremium() {
    currentScreen = _screenBeforePremium ?? AppScreen.home;
    _screenBeforePremium = null;
    _syncNotificationCount();
    notifyListeners();
  }

  void logout() {
    activeTab = AppTab.home;
    selectedPlace = null;
    _screenBeforePremium = null;
    currentScreen = AppScreen.login;
    notifyListeners();
  }

  void setSelectedPlace(Place? place) {
    selectedPlace = place;
    notifyListeners();
  }

  /// ✅ IMPORTANT: Use this from BottomNav for correct highlight + navigation
  void setActiveTab(AppTab tab) {
    if (tab == AppTab.notifications && !_isPremiumUser) {
      openPremium();
      return;
    }

    activeTab = tab;

    goTo(
      tab == AppTab.home
          ? AppScreen.home
          : tab == AppTab.explore
              ? AppScreen.explore
              : tab == AppTab.appointments
                  ? AppScreen.appointments
                  : AppScreen.notifications,
    );
  }

  /* ===== BottomNav visibility ===== */
  bool get showBottomNav =>
      currentScreen == AppScreen.home ||
      currentScreen == AppScreen.explore ||
      currentScreen == AppScreen.appointments ||
      currentScreen == AppScreen.notifications;

  /* ===== Mock Predictions ===== */
  static List<HourlyPrediction> _mockPredictions({required CrowdLevel base}) {
    final hours = ['9ص', '11ص', '1م', '3م', '5م', '7م'];

    // simple pattern around base
    List<CrowdLevel> pattern;
    switch (base) {
      case CrowdLevel.low:
        pattern = [
          CrowdLevel.low,
          CrowdLevel.low,
          CrowdLevel.medium,
          CrowdLevel.medium,
          CrowdLevel.low,
          CrowdLevel.low,
        ];
        break;
      case CrowdLevel.medium:
        pattern = [
          CrowdLevel.medium,
          CrowdLevel.high,
          CrowdLevel.high,
          CrowdLevel.medium,
          CrowdLevel.medium,
          CrowdLevel.low,
        ];
        break;
      case CrowdLevel.high:
        pattern = [
          CrowdLevel.high,
          CrowdLevel.high,
          CrowdLevel.high,
          CrowdLevel.medium,
          CrowdLevel.medium,
          CrowdLevel.high,
        ];
        break;
    }

    int valueFor(CrowdLevel lvl) {
      switch (lvl) {
        case CrowdLevel.low:
          return 25;
        case CrowdLevel.medium:
          return 55;
        case CrowdLevel.high:
          return 85;
      }
    }

    return List.generate(hours.length, (i) {
      final lvl = pattern[i];
      return HourlyPrediction(
        hour: hours[i],
        level: lvl,
        value: valueFor(lvl),
      );
    });
  }
}
