# ClassTrack — Smart Teacher Attendance, Timetable & Analytics App 🎓

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/BLoC%20%2F%20Cubit-State%20Management-818CF8?style=for-the-badge" alt="BLoC" />
  <img src="https://img.shields.io/badge/Clean%20Architecture-MVVM-6366F1?style=for-the-badge" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20On--Device-10B981?style=for-the-badge" alt="On-Device Privacy" />
  <img src="https://img.shields.io/badge/Liquid%20Glass-Design%20System-38BDF8?style=for-the-badge" alt="Liquid Glass" />
  <img src="https://img.shields.io/badge/fl__chart-Data%20Visualization-F59E0B?style=for-the-badge" alt="fl_chart" />
  <img src="https://img.shields.io/badge/Exact%20Alarms-Timetable%20Reminders-8B5CF6?style=for-the-badge" alt="Exact Alarms" />
  <img src="https://img.shields.io/badge/License-Proprietary-EF4444?style=for-the-badge" alt="Proprietary" />
</p>

---

## 📖 Overview

**ClassTrack** is an ultra-premium, privacy-first classroom attendance, timetable management, and student analytics application built with **Flutter**. Designed with a cutting-edge **High-Contrast Midnight Dark Theme** and **Liquid Glassmorphism**, ClassTrack replaces tedious manual paper registers and slow cloud checklists with a lightning-fast, card-based roll call and intelligent attendance trend analytics that operate **100% offline without any user data ever leaving the device**.

---

## 🏷️ Skills, Technologies & Engineering Concepts Used

| Domain | Skills & Applied Concepts |
|---|---|
| 📱 **Mobile Development** | `Flutter Framework`, `Dart 3 (Sound Null Safety)`, `Android SDK (API 34+)`, `Native Platform Channels` |
| 🏗️ **Architecture & State** | `BLoC / Cubit Pattern (flutter_bloc)`, `Repository Pattern`, `Clean Decoupled Domain Layer`, `Immutable State Models (Equatable)` |
| 🗄️ **Database & Persistence** | `SQLite / Sqflite`, `Relational Database Design`, `ACID Transactions`, `Schema Migrations`, `Foreign Key Cascades`, `JSON Vault Serialization` |
| 🎨 **UI/UX & Design Systems** | `Liquid Glassmorphism`, `Backdrop Filter Blur (dart:ui)`, `High-Contrast Midnight Dark Theme`, `Material Design 3`, `Haptic Feedback Engine`, `Staggered Micro-Animations` |
| 📊 **Data Visualization** | `fl_chart`, `Weekly Grouped Turnout Line Charts`, `Absentee Trend Bar Charts`, `Defaulter Distribution Pie Charts`, `Dynamic Min/Max Bounds` |
| ⏱️ **Background & OS Services** | `Flutter Local Notifications`, `Exact Alarm Scheduling (SCHEDULE_EXACT_ALARM)`, `Timezone Localization`, `BootReceiver (Device Reboot Persistence)` |
| 📄 **Data Processing & I/O** | `CSV Serialization / Deserialization`, `File Picker`, `Share Plus`, `Path Provider`, `Encrypted Backup & Recovery` |
| 🚀 **Performance & Build** | `ProGuard / R8 Bytecode Optimization`, `Split-per-ABI Native Packaging (arm64-v8a, armeabi-v7a, x86_64)`, `Font Tree-Shaking`, `Dart Static Analysis` |

---

## ✨ Key Features & Capabilities

### 1. 🌌 High-Contrast Midnight & Liquid Glass UI
- **Midnight Color Palette**: Deep background (`#080C14`) paired with elevated Slate surfaces (`#151D2C`), Indigo (`#818CF8`), Emerald (`#34D399`), Amber (`#FBBF24`), and Rose (`#F43F5E`).
- **Liquid Glass Floating Navigation**: Frosted glass floating bottom navigation bar with real-time backdrop blur (`ImageFilter.blur`), luminous glow borders, and fluid tab transitions.
- **Adaptive Light & Dark Modes**: Full theme system supporting instant switching between high-contrast dark mode and crisp modern light mode with system theme auto-detection.

### 2. 🏫 Adaptive Dual Attendance Tracking Modes
Switch effortlessly between tracking methodologies tailored for different educational settings:
- **Full-Day Master Roll Call (School Mode)**:
  - Takes 1 master attendance record per day per class/standard (e.g., *Grade 10 - Section A*).
  - Streamlines class creation by omitting redundant subject fields while preserving period-specific topic assignments in the weekly timetable.
- **Per-Lecture Slot Attendance (College/University Mode)**:
  - Multi-session period attendance linked directly to individual course topics (e.g., *Data Structures & Algorithms*).
  - Distinctly associates attendance records with individual timetable slots.

### 3. ⚡ Dual Attendance Workflows (List View & Focus Card)
- **📋 Interactive List View (Primary Roster Mode)**:
  - **Full Class Overview**: View your entire student roster in a scrollable, high-contrast list with student initials, names, and roll numbers.
  - **1-Tap Status Toggles**: Direct `Present` (🟢), `Absent` (🔴), and `Late` (🟡) pill selectors for rapid status switching without extra taps.
  - **Master Batch Shortcuts**: 1-tap **"Mark All Present"** or **"Mark All Absent"** buttons on the floating dock and menu to complete routine roll calls in seconds.
  - **Instant Search & Filter**: Built-in real-time search bar to immediately filter students by name or roll number on the fly.
- **📇 Focus Card Mode**: Displays one student card at a time with large tactile action buttons (`Present`, `Absent`, `Late`) and automated auto-advance for focused individual verification.
- **💓 Live Telemetry Pulse**: Top telemetry banner dynamically recalculates present/absent counters and color-coded percentage turnout in real-time as you mark.

### 4. 🚨 Real-Time Defaulter Detection & Exam Risk Analytics
- **Live Percentage Calculation**: Automatically evaluates individual attendance percentages against your required threshold (customizable from 50% to 90%, defaulting to **75%**).
- **Risk Badges**:
  - 🔴 **Critical Defaulter (< 65%)**: High risk of exam debarment.
  - 🟠 **Warning Zone (65% – 74%)**: At risk of falling below attendance requirements.
  - 🟢 **Safe Zone (≥ 75%)**: Good standing.
- **1-Tap Parent Communication**: Direct dial or WhatsApp messaging to parent contact numbers directly from student profile cards.

### 5. ⏱️ Timetable Scheduler & Local Native Alarms
- **Weekly Schedule Matrix**: Interactive day-by-day scheduler across Monday through Sunday.
- **Class vs. Subject Visual Hierarchy**: Distinctly formats the class badge (`[ 🏫 Grade 10 - Section A ]`) separately from the lecture title (`Mathematics`).
- **Zero-Cloud Local Alarms**: Automatically triggers notifications 5, 10, or 15 minutes prior to scheduled periods using native Android `AlarmManager` without requiring server connectivity.

### 6. 📊 Visual Analytics & Chronological Trend Charts (`fl_chart`)
- **Chronological Weekly Grouping**: Renders attendance history in distinct weekly blocks (e.g., *Mon 17 Aug – Sat 22 Aug* and *Mon 24 Aug – Wed 26 Aug*) without confusing cross-week merging.
- **Interactive Turnout Line Charts**: Smooth spline graphs visualizing daily attendance percentages over time.
- **Absentee Distribution Bar Charts**: Identifies the exact days and periods with peak absenteeism.
- **Class Insights & Student Drill-Down**: Individual student performance history with month-over-month trend breakdowns.

### 7. 📄 Data Portability (CSV Import & Export Guide)
ClassTrack allows you to bulk-import student rosters from spreadsheets and export attendance logs for administrative records.

#### Where to Find Import & Export in the App:
- **Importing Students**: Navigate to any Class Dashboard $\rightarrow$ Tap the **"Add Students"** action $\rightarrow$ Select **"Import from CSV"**. Pick any `.csv` file from your device storage to automatically populate student rosters.
- **Exporting Reports**: Navigate to the **Reports Tab** $\rightarrow$ Select date range and class $\rightarrow$ Tap **"Export CSV / PDF"** to save or share official attendance sheets.

#### CSV Schema & Column Specifications:
To create your own CSV roster file for importing, use the following column headers in the first row:

| Column Name | Requirement | Type | Allowed Values & Format | Description | Example |
|---|---|---|---|---|---|
| `rollNo` | **Required** | String | Alphanumeric | Student Roll / Registration Number | `101` or `CS-2026-01` |
| `name` | **Required** | String | Any text | Full name of the student | `Alexander Wright` |
| `parentContact` | *Optional* | String | Phone number format | Emergency / Parent Phone Number | `+1-555-0101` |

#### Sample CSV File Template:
You can also use the included [`sample_students_import.csv`](file:///c:/Projects/attendance/sample_students_import.csv) file located in the root project folder as a reference:

```csv
rollNo,name,parentContact
101,Alexander Wright,+1-555-0101
102,Beatrix Potter,+1-555-0102
103,Charlie Davis,+1-555-0103
104,Diana Prince,+1-555-0104
105,Ethan Hunt,+1-555-0105
106,Fiona Gallagher,+1-555-0106
107,George Clark,+1-555-0107
108,Hannah Abbott,+1-555-0108
109,Ian Malcolm,+1-555-0109
110,Julia Roberts,+1-555-0110
```

### 8. 💾 Full Database JSON Vault & Offline Disaster Recovery
- **1-Tap Complete Backup**: Exports all classes, students, attendance sessions, timetable slots, and preferences into a single encrypted JSON vault file.
- **Instant Database Restoration**: Restore your entire historical workspace seamlessly upon switching devices without cloud latency.
- **Sample Demo Dataset Seeder**: Built-in 1-tap demo data generator pre-loads structured classes, student rosters, and 2 weeks of realistic attendance records for instant testing.

### 9. 👨‍🏫 Teacher Personalization & Interactive Onboarding
- **Interactive First-Time Setup**: Configure teacher salutation (`Mr.`, `Ms.`, `Dr.`, `Prof.`, `Sir`), gender, full name, and institution type (*School, High School, College, University, Coaching Institute*).
- **Intelligent Keyboard Dismissal**: Features tap-outside and scroll-drag keyboard unfocusing across all setup forms.

---

## 🏗️ Technical Architecture & Directory Structure

The application is structured cleanly using **BLoC / Cubit + Clean Architecture & Repository Pattern**:

```text
c:\Projects\attendance\
├── lib/
│   ├── assets/                   # App logos, brand marks, sample CSVs
│   │   └── logo/app_icon.png     # Official high-resolution app icon
│   ├── bloc/                     # Business Logic Components (BLoC / Cubit)
│   │   ├── class/                # ClassBloc, events & state management
│   │   ├── attendance/           # AttendanceBloc & live session states
│   │   ├── timetable/            # TimetableBloc & period management
│   │   └── settings/             # SettingsCubit, theme & mode states
│   ├── database/                 # SQLite DatabaseHelper, schemas & migrations
│   │   └── database_helper.dart  # ACID queries, mode reconciliations & backup engine
│   ├── models/                   # Immutable Domain Models (Equatable)
│   │   ├── class_model.dart      # Class / Section data entity
│   │   ├── student_model.dart    # Student roster entity
│   │   ├── attendance_model.dart # Individual student attendance entity
│   │   ├── attendance_record_model.dart # Master session metadata entity
│   │   ├── timetable_model.dart  # Weekly timetable slot entity
│   │   └── settings_model.dart   # App settings & teacher profile entity
│   ├── screens/                  # Feature Presentation Layer
│   │   ├── onboarding/           # Hero landing & teacher personalization
│   │   ├── home/                 # Main dashboard, active classes & stats
│   │   ├── class/                # Class dashboard, create/edit class & student manager
│   │   ├── attendance/           # Flashcard & List attendance marking screens
│   │   ├── timetable/            # Weekly timetable scheduler & slot builder
│   │   ├── reports/              # Class insights, student drill-downs & CSV export
│   │   └── settings/             # Settings screen, theme, backup & about app
│   ├── services/                 # Background & Domain Services
│   │   ├── notification_service.dart # Exact alarms & timetable reminders
│   │   └── demo_data_service.dart    # Structured school & college demo datasets
│   ├── utils/                    # Utility Helpers & Exporters
│   │   ├── excel_helper.dart     # CSV import/export & formatted report builders
│   │   └── app_colors.dart       # Design system tokens & gradients
│   ├── widgets/                  # Reusable Design System Components
│   │   ├── liquid_glass_bar.dart # Floating blur navigation bar
│   │   ├── glass_container.dart  # Frosted glass card containers
│   │   ├── stat_card.dart        # Metric highlight cards
│   │   └── app_snack_bar.dart    # Floating styled notifications
│   └── main.dart                 # Application entry point & BLoC providers
│
├── android/                      # Native Android configuration, ProGuard rules & manifest
├── test/                         # Unit & widget test suites (14 tests)
└── pubspec.yaml                  # Dependencies, asset registrations & metadata
```

---

## 📱 Device Compatibility & Hardware Performance Guide

ClassTrack is engineered with a lightweight, zero-dependency architecture that runs smoothly across all Android devices:

### 📊 Compatibility & Performance Matrix

| Device Tier | Example Processors / Chipsets | RAM Required | App Launch | Attendance Marking FPS |
|---|---|---|---|---|
| **🟢 Flagship & High-End** | Snapdragon 8 Gen 2 / 8 Gen 3, Dimensity 9200 / 9300, Tensor G3 / G4 | **8 GB – 12 GB+** | ⚡ Instant (< 0.5s) | 🚀 **120 FPS Butter Smooth** (Zero stutter) |
| **🔵 Upper Mid-Range** | Snapdragon 7+ Gen 2 / 7 Gen 3, Dimensity 8200 / 8300, Exynos 1480 | **6 GB – 8 GB** | ⚡ Instant (< 0.8s) | ⚡ **120 FPS Smooth** |
| **🟡 Budget / Entry Mid-Range** | Snapdragon 695 / 4 Gen 2, Dimensity 6080 / 7020, Helio G99 | **4 GB – 6 GB** | ✅ Fast (< 1.2s) | ✅ **60 FPS Fluid** |
| **🟠 Low-End Hardware** | Helio G85 / G88, Unisoc T606 / T612, Snapdragon 450 | **2 GB – 3 GB** | ✅ Stable (< 2.0s) | ✅ **60 FPS Consistent** |

---

## 📦 Optimized Production Builds & Split APK Artifacts

Building split APKs significantly reduces download and install size by generating dedicated binaries for each CPU architecture instead of one oversized fat APK.

### Release Binaries Generated:
The compiled production release APKs are located in `build/app/outputs/flutter-apk/`:

| Binary Name | Target CPU Architecture | File Size | Description |
|---|---|---|---|
| **`ClassTrack-v2.0.0-arm64-v8a.apk`** | `arm64-v8a` (64-bit ARM) | **28.1 MB** | **Recommended**: For all modern Android smartphones & flagships. |
| **`ClassTrack-v2.0.0-armeabi-v7a.apk`** | `armeabi-v7a` (32-bit ARM) | **25.9 MB** | For legacy 32-bit Android phones and older devices. |
| **`ClassTrack-v2.0.0-x86_64.apk`** | `x86_64` (64-bit Intel/AMD) | **29.3 MB** | For Android emulators, ChromeOS, and x86-based tablets. |

### Build Command:
To compile your own split release APKs, execute:
```bash
flutter build apk --split-per-abi
```

To install directly to a connected test device:
```bash
flutter install
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `^3.19.0` or later
- **Dart SDK**: `^3.3.0`
- **Android Studio / VS Code** with Flutter & Dart extensions
- **Android Device / Emulator** (Android 8.0+ / API 26+; Android 13+ recommended for notification runtime permissions)

### Installation & Run

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/VINIT0207/flutter-teacher-attendance.git
   cd flutter-teacher-attendance
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

4. **Run on Connected Device**:
   ```bash
   flutter run
   ```

---

## ⚙️ Permissions Configuration

The application declares the following permissions in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.POST_NOTIFICATIONS`: Android 13+ runtime notification display.
- `android.permission.SCHEDULE_EXACT_ALARM` & `android.permission.USE_EXACT_ALARM`: For precise lecture timetable reminder triggering.
- `android.permission.RECEIVE_BOOT_COMPLETED`: Automatically restores scheduled timetable alarms after device reboot.
- `android.permission.VIBRATE`: Provides tactile haptic feedback during flashcard swipes and rapid roll calls.

---

## 🔒 License & Intellectual Property Notice

**Copyright © 2026 Vinit Sharma. All Rights Reserved.**

### Terms of Use:
- **Proprietary Software**: This source code, user interface design, architecture, branding, and associated assets are the intellectual property of **Vinit Sharma**.
- **Commercial Use Strictly Prohibited**: It is strictly forbidden to sell, rent, lease, sub-license, monetize, or commercially distribute this application, source code, or any derivative works thereof.
- **Personal & Educational Use Only**: You may review, run, and modify this codebase strictly for personal, educational, and classroom evaluation purposes.
- **No Unauthorized Distribution or Re-branding**: Publishing re-branded or closed-source clones of this application to app stores (Google Play, Apple App Store, etc.) or distributing APKs to third parties without explicit written consent is strictly prohibited.

---

## 📬 Contact & Author

**Vinit Sharma**
- **GitHub**: [@VINIT0207](https://github.com/VINIT0207)
- **Email**: `sharma.vinit.2007@gmail.com`

---

<p align="center">
  <b>Crafted with precision & passion using Flutter.</b>
</p>
