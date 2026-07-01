<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.x">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3.x">
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web%20|%20Desktop-6A47E0?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="MIT License">
</div>

<br>

<h1 align="center">📦 হিসাবনামা — HishabNama</h1>

<p align="center">
  <strong>বাংলা ভাষায় ইনভেন্টরি ম্যানেজমেন্ট অ্যাপ</strong><br>
  <em>A full-featured Bangla inventory management app built with Flutter.</em>
</p>

<p align="center">
  ট্র্যাক করুন আপনার পণ্য, বিক্রয়, এবং লাভ-লোকসান — সম্পূর্ণ বাংলায়, সম্পূর্ণ অফলাইনে।<br>
  <em>Track products, sales, and profit/loss — entirely in Bangla, entirely offline.</em>
</p>

---

## ✨ বৈশিষ্ট্য (Features)

| Feature               | Details                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------ |
| 🏠 **ড্যাশবোর্ড**     | মোট স্টক মূল্য, চলতি মাসের বিক্রি/আয়/লাভ, সেলস ট্রেন্ড চার্ট, দ্রুত অ্যাড বাটন, কম স্টক সতর্কতা |
| ➕ **পণ্য যোগ**       | নাম, পরিমাণ, একক, খরচ ও বিক্রয়মূল্য সহ পণ্য এন্ট্রি                                             |
| 💰 **বিক্রয় রেকর্ড** | পণ্য নির্বাচন → পরিমাণ ও দাম → স্বয়ংক্রিয় স্টক হ্রাস ও লাভ গণনা                                |
| 📋 **পণ্যের তালিকা**  | সার্চেবল কার্ড ভিউ, বিস্তারিত শীট (মোট যোগ/বিক্রি, এডিট, ডিলিট)                                  |
| 📊 **বিক্রয় ইতিহাস** | সার্চ/ফিল্টার, তারিখ অনুযায়ী সাজানো, প্রতি বিক্রয়ের লভ্যাংশ                                    |
| 📈 **রিপোর্ট**        | তারিখ রেঞ্জ পিকার, আয়/ব্যয়/লাভ বার চার্ট, পণ্য ভিত্তিক ব্রেকডাউন                               |
| 🎨 **থিম**            | Material Design 3, Purple Theme, বাংলা ফন্ট (Hind Siliguri), বাংলা সংখ্যা (০১২৩...)              |
| 💾 **অফলাইন স্টোরেজ** | `shared_preferences`-এ JSON এনকোডেড ডাটা সংরক্ষণ — no backend needed                             |

---

## 🚀 দ্রুত শুরু (Quick Start)

```bash
# 1. Clone
git clone https://github.com/Imon-selise/flutter-hisabnama.git
cd flutter_hishabnama

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run                  # Connected device / emulator
flutter run -d chrome        # Web (fastest for testing)
```

> **Note:** This app uses `google_fonts` and `shared_preferences` plugins. It will **not** run in DartPad — a real Flutter SDK / device / emulator is required.

---

## 📱 Screenshots

> _Coming soon — add your app screenshots here._

| Home Dashboard                | Add Product/Sale            | Inventory                               | Reports                             |
| ----------------------------- | --------------------------- | --------------------------------------- | ----------------------------------- |
| ![Home](screenshots/home.png) | ![Add](screenshots/add.png) | ![Inventory](screenshots/inventory.png) | ![Reports](screenshots/reports.png) |

---

## 🏗️ প্রজেক্ট স্ট্রাকচার (Project Structure)

```
lib/
├── main.dart                            # Entry point — initializes Store, runs app
├── app.dart                             # MaterialApp with theme & font config
├── config/
│   └── constants.dart                   # Colors, gradients, bn() formatter
├── models/
│   ├── addition.dart                    # Addition model (stock-in records)
│   ├── product.dart                     # Product model (id, name, qty, cost, price)
│   └── sale.dart                        # Sale model (id, productId, qty, price, cost)
├── store/
│   └── store.dart                       # Singleton Store (ChangeNotifier) + JSON persistence
├── screens/
│   ├── root_screen.dart                 # Scaffold with IndexedStack + BottomNav + Drawer
│   ├── home_tab.dart                    # Dashboard — summary cards, chart, low-stock alerts
│   ├── add_tab.dart                     # Add product / Record sale forms
│   ├── inventory_tab.dart               # Searchable product grid with detail sheets
│   ├── sales_tab.dart                   # Sales history list with search/filter
│   └── reports_tab.dart                 # Date-range reports with charts & breakdowns
└── widgets/
    ├── drawer.dart                      # Navigation drawer
    ├── product_card.dart                # Product card widget
    └── ...                              # Shared widgets (shared_widgets.dart, etc.)
```

---

## 📦 Dependencies

| Package                                                           | Version | Purpose             |
| ----------------------------------------------------------------- | ------- | ------------------- |
| [flutter](https://flutter.dev)                                    | SDK     | Framework           |
| [google_fonts](https://pub.dev/packages/google_fonts)             | ^6.2.1  | বাংলা ফন্ট          |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.2.3  | অফলাইন ডাটা স্টোরেজ |
| [cupertino_icons](https://pub.dev/packages/cupertino_icons)       | ^1.0.6  | iOS-style icons     |
| [flutter_lints](https://pub.dev/packages/flutter_lints) (dev)     | ^3.0.0  | Lint rules          |

---

## 🔧 Build & Deploy

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)

```bash
flutter build ios --release
# Then archive via Xcode
```

### Web

```bash
flutter build web --release
# Output: build/web/
```

---

## 🗄️ Data Persistence

- **Storage:** `shared_preferences` — all data persists as JSON under key `hishabnama_flutter_v1`
- **First launch:** Automatically seeded with sample products & sales for demo
- **Reset data:** Uninstall & reinstall the app, or clear app storage from device settings

---

## 🧪 Run Tests

```bash
flutter test
```

---

## 🛠️ Tech Stack

| Layer                | Technology                                                 |
| -------------------- | ---------------------------------------------------------- |
| **Framework**        | Flutter 3.x                                                |
| **Language**         | Dart 3.x                                                   |
| **State Management** | `ChangeNotifier` + `ListenableBuilder` / `AnimatedBuilder` |
| **Persistence**      | `shared_preferences` (JSON)                                |
| **Typography**       | Google Fonts — Hind Siliguri (Bengali)                     |
| **Design**           | Material Design 3 (M3)                                     |
| **Architecture**     | Singleton Store pattern                                    |

---

## 🤝 Contribute

Contributions, issues, and feature requests are welcome!  
Feel free to check the [issues page](https://github.com/Imon-selise/flutter-hisabnama/issues).

---

## 📄 License

This project is **MIT Licensed** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Made with ❤️ for the Bangla-speaking community</sub>
  <br>
  <sub>বাংলা ভাষাভাষী সম্প্রদায়ের জন্য তৈরি</sub>
</div>
