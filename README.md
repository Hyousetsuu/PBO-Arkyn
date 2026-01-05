# Arkyn

Arkyn is a cross-platform application built using Flutter, allowing the app to run on Android, iOS, Web, and Desktop platforms (Windows, macOS, Linux).

This project is currently in its initial development stage and is based on the default Flutter project template. It is intended for academic purposes and can be further developed according to project requirements.

---

## Features (Planned / Placeholder)

- Cross-platform user interface (Android, iOS, Web, Desktop)
- Responsive and modern UI design
- User authentication system
- API integration
- Local data storage (SQLite / Hive)
- Scalable Flutter application architecture

---

## Project Structure

android/  
Android platform configuration  

ios/  
iOS platform configuration  

lib/  
Main Flutter source code (Dart)  

web/  
Web platform configuration  

windows/, macos/, linux/  
Desktop platform configuration  

test/  
Unit and widget tests  

pubspec.yaml  
Project metadata and dependencies  

---

## Requirements

Before running this project, make sure you have installed:

- Flutter SDK version 3.x or newer  
  https://flutter.dev/docs/get-started/install
- Android Studio or Visual Studio Code with Flutter extension
- Android emulator, iOS simulator, or physical device
- Optional: Desktop platform support enabled

---

## Getting Started

Clone the repository:

```bash
git clone https://github.com/Hyousetsuu/PBO-Arkyn.git
cd PBO-Arkyn
Install dependencies:

bash
flutter pub get
Run the application:

bash
flutter run
Run on a specific platform:

bash
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d windows
Testing
Run unit tests using:

bash
flutter test
Dependencies
All dependencies used in this project are defined and managed in the pubspec.yaml file.

Contributing
Contributions are welcome.
Please fork this repository, create a new feature branch, and submit a pull request.

License
This project is open-source and distributed under the license specified in this repository.

Notes
This repository is based on a Flutter starter template.

The project is suitable for academic purposes, learning Flutter, and application prototyping.

Additional features and improvements can be added in future development.
