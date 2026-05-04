# تحديثات التوطين والمواضيع

## الميزات المضافة:

### 1. دعم اللغات 🌍
- **العربية (ar)**: اللغة الافتراضية
- **الإنجليزية (en)**: دعم كامل

تبديل اللغة يتم عبر:
- زر الإعدادات في الـ AppBar (أيقونة الترس)
- اختيار اللغة من قائمة Segmented Button

### 2. المواضيع 🌓
- **وضع مظلم (Dark Mode)**: الوضع الافتراضي
- **وضع فاتح (Light Mode)**: وضع بديل

تبديل الوضع يتم عبر:
- زر في الـ AppBar (أيقونة الشمس/القمر)
- أو من خلال Segmented Button في الإعدادات

## الملفات المُضافة:

### 1. `lib/l10n/app_localizations.dart`
يحتوي على قاموس الترجمات لكل اللغات المدعومة.

**مثال الاستخدام:**
```dart
final label = context.getString('appTitle'); // استخدم Extension
```

### 2. `lib/theme/app_theme.dart`
يحتوي على تعاريف المواضيع:
- `AppThemes.darkTheme`: الموضوع المظلم
- `AppThemes.lightTheme`: الموضوع الفاتح

### 3. `lib/extensions/localization_extension.dart`
توفر methods سهلة الاستخدام:
- `context.getString(key)`: الحصول على ترجمة
- `context.isArabic`: التحقق إذا كانت اللغة عربية
- `context.textDirection`: الحصول على اتجاه النص

### 4. `lib/widgets/settings_widget.dart`
واجهة الإعدادات للتحكم في اللغة والموضوع

## كيفية إضافة ترجمات جديدة:

1. افتح `lib/l10n/app_localizations.dart`
2. أضف المفتاح الجديد في القاموس لكل لغة:
```dart
const Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'myKey': 'My English Text',
    // أضف مفتاحك هنا
  },
  'ar': {
    'myKey': 'نصي بالعربية',
    // أضف مفتاحك هنا
  },
};
```

3. استخدمه في الشاشات:
```dart
Text(context.getString('myKey'))
```

## تطبيقات الموضوع:

يتم تطبيق الألوان تلقائياً عند تبديل الموضوع. استخدم الألوان من `Theme`:

```dart
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyLarge,
),
Container(
  color: Theme.of(context).cardColor,
)
```

## ملاحظات مهمة:

- `AppState` الآن تدير `_locale` و `_isDarkMode`
- كل تغيير في اللغة أو الموضوع يؤدي لـ `notifyListeners()`
- استخدم `Consumer<AppState>` أو `context.read<AppState>()` للوصول للحالة
