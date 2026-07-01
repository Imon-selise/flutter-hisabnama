# হিসাবনামা — HishabNama (Flutter)

A Bangla inventory-management app. Flutter port of the design — same purple UI, Bengali numerals (৳, ১২৩), and offline persistence.

## Features
- **হোম (Dashboard):** total stock value, items sold / revenue / profit this month, monthly sales-trend bar chart, quick add buttons, low-stock alert.
- **যোগ করুন (Add):** toggle between *পণ্য যোগ* (add product) and *বিক্রয় করুন* (record sale). Selling auto-deducts stock; over-selling shows a warning but is still allowed.
- **পণ্য সমূহ (Inventory):** searchable product cards (cost / stock / stock value). Tap a card → detail sheet with total added, total sold, edit-sell, delete.
- **বিক্রয় (Sales):** search/filter, newest first, per-sale qty / unit price / total / profit.
- **রিপোর্ট (Reports):** date-range picker, result cards (added, sold, revenue, COGS, profit/loss, remaining stock value), revenue·cost·profit bar chart, per-product breakdown.
- **Drawer** with profile + navigation.
- **Persistent storage** via `shared_preferences` — data survives app restarts. Seeded with sample products/sales on first launch.

## Requirements
- Flutter SDK 3.x (Dart >= 3.0). Check with `flutter --version`.

## Run it
```bash
cd flutter_hishabnama
flutter pub get

# pick one target:
flutter run                 # connected device / emulator
flutter run -d chrome       # web (quickest to test)
```

> Note: this app uses the `google_fonts` and `shared_preferences` plugins, so it needs a real Flutter SDK / device / emulator — it will **not** run in DartPad.

## Build a release APK (Android)
```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

## Structure
- `lib/main.dart` — entire app (models, `Store` with persistence + seed data, all 5 screens, drawer, charts).
- `pubspec.yaml` — dependencies.

## Reset data
Delete & reinstall the app, or clear app storage — first launch re-seeds the sample data.
