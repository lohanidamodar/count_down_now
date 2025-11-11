# CountDownNow 🎉

A beautiful, production-ready Flutter Web app for creating and sharing countdown timers for special events.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![Appwrite](https://img.shields.io/badge/Appwrite-20.3.0-F02E65?logo=appwrite)

## ✨ Features

- 🎨 **Beautiful Countdown Pages** - Create stunning countdown timers with customizable themes
- 🎯 **Event Customization** - Choose emojis, colors, and themes for your countdowns
- 🔗 **Shareable Links** - Get unique URLs to share your countdowns (e.g., `/c/abc12345`)
- 👤 **User Authentication** - Optional login to save and manage your countdowns
- 📱 **Responsive Design** - Works seamlessly on desktop and mobile web
- ⚡ **Real-time Updates** - Live countdown that updates every second
- 💾 **Persistent Storage** - Save countdowns to Appwrite or use in-memory for anonymous users

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- An Appwrite account and project

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd count_down_now
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Appwrite**

   Create an Appwrite project and configure:

   - **Database**: Create a new database
   - **Collection**: Create a collection named "countdowns" with these attributes:
     - `slug` (String, 255, required)
     - `title` (String, 255, required)
     - `description` (String, 1000, optional)
     - `emoji` (String, 10, optional)
     - `targetDateTime` (DateTime, required)
     - `themeColor` (String, 100, required)
     - `ownerId` (String, 255, optional)
     - `isPublic` (Boolean, required, default: true)
   
   - **Indexes**: Create an index on `slug` for fast lookup
   - **Permissions**: Configure as needed (read access for everyone, write for authenticated users)

4. **Configure Appwrite credentials**

   **Option A: Using Environment Variables (Recommended)**
   
   Create a `.env` file:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your values:
   ```env
   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
   APPWRITE_PROJECT_ID=your-project-id
   APPWRITE_DATABASE_ID=your-database-id
   APPWRITE_COLLECTION_ID=your-collection-id
   ```
   
   See [ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md) for detailed configuration options.

   **Option B: Direct Code Configuration**
   
   Edit `lib/core/app_config.dart` and replace the default values.

### Development

Run the app in development mode:

**Using helper script (reads from .env):**
```bash
.\run-dev.ps1        # Windows PowerShell
./run-dev.sh         # Mac/Linux
```

**Manual run:**
```bash
flutter run -d chrome --dart-define=APPWRITE_PROJECT_ID=your-id
```

**Without Appwrite (anonymous mode):**
```bash
flutter run -d chrome
```

### Building for Production

Build the web app:

**Using helper script (reads from .env):**
```bash
.\build-web.ps1      # Windows PowerShell
./build-web.sh       # Mac/Linux
```

**Manual build with environment variables:**
```bash
flutter build web --release \
  --dart-define=APPWRITE_PROJECT_ID=your-prod-id \
  --dart-define=APPWRITE_DATABASE_ID=your-prod-db \
  --dart-define=APPWRITE_COLLECTION_ID=your-prod-collection
```

The output will be in `build/web/`.

## 🌐 Deploying to Appwrite Sites

1. **Build the app with production config**
   ```bash
   .\build-web.ps1  # Ensure .env has production values
   ```

2. **Deploy to Appwrite**
   - Go to your Appwrite Console
   - Navigate to your project
   - Go to "Functions" → "Sites" (or use Appwrite CLI)
   - Upload the contents of `build/web/` directory

3. **Configure routing**
   - Ensure your Appwrite Sites configuration supports client-side routing
   - Add a rewrite rule to redirect all paths to `index.html`

## 📁 Project Structure

```
lib/
├── core/
│   ├── app_config.dart       # Appwrite configuration
│   └── app_theme.dart         # Theme and color definitions
├── models/
│   └── countdown.dart         # Countdown data model
├── services/
│   ├── appwrite_client.dart   # Appwrite SDK initialization
│   ├── auth_service.dart      # Authentication logic
│   └── countdown_repository.dart  # Database operations
├── pages/
│   ├── home_page.dart         # Landing page with quick create
│   ├── create_edit_countdown_page.dart  # Full create/edit form
│   ├── countdown_view_page.dart  # Public countdown display
│   ├── dashboard_page.dart    # User's countdowns management
│   └── login_page.dart        # Authentication page
├── app_router.dart            # GoRouter configuration
└── main.dart                  # App entry point
```

## 🎨 Customization

### Adding New Themes

Edit `lib/core/app_theme.dart` and add new `CountdownTheme` presets:

```dart
CountdownTheme(
  name: 'Your Theme',
  primaryColor: Color(0xFF..),
  secondaryColor: Color(0xFF..),
  isGradient: true,
),
```

### Adding More Emojis

Edit the `_popularEmojis` list in `home_page.dart` or `create_edit_countdown_page.dart`.

## 🔐 Authentication

The app supports email/password authentication via Appwrite:

- **Anonymous Mode**: Create temporary countdowns (in-memory only)
- **Authenticated Mode**: Save countdowns permanently and manage them from the dashboard

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 💡 Tips

- For local development with Appwrite, you may need to adjust CORS settings
- Use `.env` files for different environments (development, staging, production)
- Consider adding analytics and error tracking for production use
- Implement rate limiting on the backend to prevent abuse

## 🐛 Known Issues

- Ensure Appwrite collection IDs are correctly configured before first run
- Browser may cache old countdown data; clear cache if experiencing issues

## 📧 Support

For issues and questions, please open an issue on GitHub.

---

Made with ❤️ using Flutter and Appwrite
