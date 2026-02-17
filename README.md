# MCI Booking App

> ⚠️ **Development Build** - This project is currently under active development and not yet finished.

A Flutter-based room booking application for MCI (Management Center Innsbruck) that allows students and staff to book rooms efficiently.

## 📱 Features

- User authentication and authorization
- Room availability checking
- Room booking management
- View and manage personal bookings
- Real-time booking status updates
- Equipment filtering for rooms
- User profile management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd MCIBookingApp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🔧 Development Setup

### Backend API

The app connects to the backend API hosted at:
```
https://roombooking-backend-l7kv.onrender.com
```

**Note:** The backend may take a moment to boot up on first access.

### User Registration

To register a new user for development/testing, use the Swagger UI at:
https://roombooking-backend-l7kv.onrender.com/swagger

**Example registration payload:**
```json
{
  "email": "test@test.com",
  "password": "abcdefgh",
  "firstName": "John",
  "lastName": "Marx",
  "role": "STUDENT",
  "permissionLevel": "USER"
}
```

### CORS Proxy

If you encounter CORS issues during development, you can activate the CORS proxy by visiting:
https://cors-anywhere.herokuapp.com/corsdemo

## 📁 Project Structure

```
lib/
├── Helper/           # Helper utilities and HTTP client
├── Models/           # Data models and enums
├── Resources/        # App constants (colors, strings, dimensions, API)
├── Screens/          # UI screens
├── Services/         # Business logic and API services
└── Widgets/          # Reusable UI components
```

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Dart](https://dart.dev/) - Programming language
- HTTP package for API communication

## 📄 License

This project is part of an academic project at MCI.

## 👥 Authors

MCI Students - Integratives Gesamtprojekt

## 🤝 Contributing

This is an academic project. For any questions or contributions, please contact the project maintainers.
