# 🎓 ClassTrack v2.0.0 — Production Release Notes

<p align="center">
  <img src="https://img.shields.io/badge/Release-v2.0.0-02569B?style=for-the-badge&logo=github&logoColor=white" alt="Release v2.0.0" />
  <img src="https://img.shields.io/badge/Flutter-3.x-0175C2?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.x" />
  <img src="https://img.shields.io/badge/Architecture-BLoC%20%2F%20Cubit-818CF8?style=for-the-badge" alt="BLoC Architecture" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20On--Device-10B981?style=for-the-badge" alt="100% On-Device" />
  <img src="https://img.shields.io/badge/License-Proprietary-EF4444?style=for-the-badge" alt="Proprietary License" />
</p>

---

## 🏷️ Release Metadata
* **Version**: `v2.0.0`
* **Release Title**: `ClassTrack v2.0.0 — Smart Offline Attendance, Timetable Reminders & Analytics`
* **Target Platforms**: Android (API 21+), iOS, Desktop
* **Author & Lead Developer**: Vinit Sharma ([@VINIT0207](https://github.com/VINIT0207))
* **License**: Copyright © 2026 Vinit Sharma. All Rights Reserved (Personal & Educational Use Only).

---

## ✨ What's New in v2.0.0

### 1. 🌌 High-Contrast Midnight & Liquid Glass Design System
* **Liquid Glass Floating Navigation (`LiquidGlassBar`)**: Frosted glass floating navigation bar with real-time backdrop blur (`ImageFilter.blur`), luminous glow borders, and fluid tab transitions.
* **Adaptive Theme Engine**: Seamless support for High-Contrast Midnight Obsidian Dark Mode (`#080C14`) and Crisp Modern Light Mode with system theme auto-detection.
* **Ambient Glow Badges & Squircle Cards**: Elevated cards with haptic micro-interactions and smooth staggered list animations.

### 2. 🏫 Adaptive Dual Attendance Tracking Modes
* **Full-Day Master Roll Call (School Mode)**:
  - Takes 1 master attendance record per day per class/standard.
  - Automatically streamlines class creation by hiding redundant subject prompts while preserving specific subject assignments in the weekly timetable.
* **Per-Lecture Slot Attendance (College/University Mode)**:
  - Multi-session period attendance linked directly to individual course topics (e.g., *Data Structures & Algorithms*).
  - Explicit timetable association per attendance session.

### 3. ⚡ Dual Attendance Workflows (List View & Focus Card)
* **📋 Interactive List View (Primary Roster Mode)**:
  - **Full Class Overview**: Scrollable, high-contrast table view displaying every student's initials, name, and roll number simultaneously.
  - **1-Tap Status Toggles**: Direct `Present` (🟢), `Absent` (🔴), and `Late` (🟡) pill selectors for zero-friction status updates.
  - **Master Batch Shortcuts**: 1-tap **"Mark All Present"** or **"Mark All Absent"** buttons on the floating dock and menu to complete routine roll calls in seconds.
  - **Instant Search & Filter**: Real-time search bar to instantly find students by name or roll number.
* **📇 Focus Card Mode**: Presents one student card at a time with large tactile buttons (`Present`, `Absent`, `Late`) and automated auto-advance for focused verification.
* **💓 Live Telemetry Pulse**: Real-time progress bar and live counters for present, absent, and late students with color-coded percentage turnout updated with every action.

### 4. 🚨 Real-Time Defaulter Detection & Exam Risk Analytics
* **Automated Threshold Evaluation**: Calculates live attendance percentages against customizable exam eligibility criteria (default: **75%**).
* **Defaulter Risk Badges**:
  - 🔴 **Critical Defaulter (< 65%)**: High risk of exam debarment.
  - 🟠 **Warning Zone (65% – 74%)**: Approaching minimum threshold.
  - 🟢 **Safe Zone (≥ 75%)**: Good standing.
* **1-Tap Parent Communication**: Direct dial and WhatsApp messaging to parent contact numbers directly from student profile cards.

### 5. ⏱️ Timetable Scheduler & Local Native Alarms
* **Weekly Schedule Matrix**: Interactive day-by-day timetable builder across Monday through Sunday.
* **Distinct Class vs. Subject Hierarchy**: Visual badges (`[ 🏫 Grade 10 - Section A ]`) distinctly separated from lecture topics (`Mathematics`).
* **Zero-Cloud Local Alarms**: Automatically triggers notifications 5, 10, or 15 minutes prior to scheduled periods using Android `AlarmManager` without requiring any cloud server or internet connection (`BootReceiver` supported).

### 6. 📊 Visual Analytics & Chronological Trend Charts (`fl_chart`)
* **Weekly Grouped Blocks**: Renders attendance history in chronological weekly blocks (e.g., *Mon 17 Aug – Sat 22 Aug* and *Mon 24 Aug – Wed 26 Aug*) without cross-week weekday merging.
* **Interactive Line & Bar Charts**: Daily turnout trends, absenteeism distributions, and individual student performance drill-downs.
* **Exportable Reports**: Generate instant PDF summaries and CSV logs for administrative filing.

### 7. 📄 Data Portability & JSON Vault Disaster Recovery
* **CSV Roster Import / Export**: Bulk import student rosters from CSV templates with auto-detected columns (`rollNo`, `name`, `parentContact`).
* **1-Tap Complete Database Backup**: Exports all classes, students, attendance logs, timetable slots, and preferences into a single encrypted JSON vault.
* **Instant Disaster Recovery**: Restore your entire workspace seamlessly upon switching devices with zero cloud lag.
* **1-Tap Demo Dataset Seeder**: Built-in realistic School and College sample datasets for instant testing.

### 8. 👨‍🏫 Teacher Personalization & Onboarding Setup
* **Interactive First-Time Setup**: Configure teacher salutation (`Mr.`, `Ms.`, `Dr.`, `Prof.`, `Sir`), gender, full name, and institution type (*School, High School, College, University, Coaching*).
* **Intelligent Keyboard Dismissal**: Features tap-outside and scroll-drag keyboard unfocusing across all forms.

---

## 📦 Production Release Artifacts (Split APKs)

Download the dedicated split APK matching your device CPU architecture for the fastest installation and smallest file size:

| Artifact Name | Architecture | Size | Recommended Target Devices |
|:---|:---:|:---:|:---|
| **`ClassTrack-v2.0.0-arm64-v8a.apk`** | `arm64-v8a` (64-bit) | **28.1 MB** | **All modern Android smartphones & flagships** (Snapdragon, MediaTek, Exynos, Tensor) |
| **`ClassTrack-v2.0.0-armeabi-v7a.apk`** | `armeabi-v7a` (32-bit) | **25.9 MB** | Older 32-bit Android phones and legacy devices |
| **`ClassTrack-v2.0.0-x86_64.apk`** | `x86_64` (64-bit) | **29.3 MB** | Android emulators, ChromeOS, and Intel/AMD tablets |

---

## 🔧 Bug Fixes & Stability Improvements
* **Layout & Rendering**: Fixed `RenderFlex overflow` on onboarding screens for compact viewports by wrapping in responsive `LayoutBuilder` and `SingleChildScrollView`.
* **Keyboard UX**: Wrapped root views with tap-anywhere `GestureDetector` to dismiss the keyboard immediately on tap or scroll.
* **Navigation Clearance**: Added safe bottom padding (`MediaQuery.paddingOf(context).bottom + 130px`) to all empty states and settings lists to prevent the floating bottom navigation bar from obscuring action buttons.
* **ProGuard / R8 Rules**: Configured production ProGuard rules (`android/app/proguard-rules.pro`) with play-core suppressions and desugaring keep directives, resolving release build minification errors.
* **Test Suite**: Verified all **14 unit & widget test suites** passing with 0 analyzer issues.

---

## 🔒 Copyright & Terms
**Copyright © 2026 Vinit Sharma. All Rights Reserved.**  
This release is distributed for **personal, classroom, and educational use**. Redistribution, commercialization, sublicensing, and unauthorized public re-branding are strictly prohibited.
