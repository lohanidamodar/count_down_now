# VS Code Setup Guide

## Quick Start

VS Code is pre-configured with launch configurations that use environment variables for Appwrite credentials.

## Launch Configurations

The project includes 5 pre-configured launch configurations in `.vscode/launch.json`:

### 1. CountDownNow (Development)
- **Purpose**: Main development configuration
- **Device**: Default Flutter device
- **Configuration**: Uses development environment variables

### 2. CountDownNow (Anonymous Mode)
- **Purpose**: Test without Appwrite backend
- **Device**: Default Flutter device
- **Configuration**: No Appwrite variables (in-memory storage only)

### 3. CountDownNow (Chrome)
- **Purpose**: Run specifically on Chrome browser
- **Device**: Chrome
- **Configuration**: Uses development environment variables

### 4. CountDownNow (Production)
- **Purpose**: Test with production credentials
- **Device**: Default Flutter device
- **Configuration**: Uses production environment variables (separate set)

### 5. CountDownNow (Profile Mode)
- **Purpose**: Performance profiling
- **Device**: Default Flutter device
- **Configuration**: Profile mode with development environment variables

## Configuration Methods

### Method 1: Edit launch.json Directly (Quick Setup)

1. Open `.vscode/launch.json`
2. Find the configuration you want to use (e.g., "CountDownNow (Development)")
3. Update the `env` section:

```json
"env": {
  "APPWRITE_ENDPOINT": "https://cloud.appwrite.io/v1",
  "APPWRITE_PROJECT_ID": "your-actual-project-id",
  "APPWRITE_DATABASE_ID": "your-actual-database-id",
  "APPWRITE_COLLECTION_ID": "your-actual-collection-id"
}
```

4. Press F5 or click "Run and Debug" → Select configuration → Start Debugging

### Method 2: Using .env File (Recommended)

1. **Create .env file**:
   ```bash
   cp .env.example .env
   ```

2. **Edit .env** with your credentials:
   ```env
   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
   APPWRITE_PROJECT_ID=your-project-id
   APPWRITE_DATABASE_ID=your-database-id
   APPWRITE_COLLECTION_ID=your-collection-id
   ```

3. **Modify launch.json** to use system environment:
   
   Update the configuration to use `${env:VARIABLE_NAME}` which reads from system environment:
   
   ```json
   "env": {
     "APPWRITE_ENDPOINT": "${env:APPWRITE_ENDPOINT}",
     "APPWRITE_PROJECT_ID": "${env:APPWRITE_PROJECT_ID}",
     "APPWRITE_DATABASE_ID": "${env:APPWRITE_DATABASE_ID}",
     "APPWRITE_COLLECTION_ID": "${env:APPWRITE_COLLECTION_ID}"
   }
   ```

4. **Load .env before opening VS Code**:
   
   **PowerShell**:
   ```powershell
   # Load .env into environment
   Get-Content .env | ForEach-Object {
       if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
           $name = $matches[1].Trim()
           $value = $matches[2].Trim()
           [Environment]::SetEnvironmentVariable($name, $value, "Process")
       }
   }
   
   # Then start VS Code
   code .
   ```
   
   **Bash/Zsh**:
   ```bash
   # Load .env and start VS Code
   export $(cat .env | grep -v '^#' | xargs) && code .
   ```

### Method 3: VS Code Settings (Advanced)

1. **Create a local settings file** (git-ignored):
   ```
   .vscode/settings.local.json
   ```

2. **Add your environment variables**:
   ```json
   {
     "dart.env": {
       "APPWRITE_ENDPOINT": "https://cloud.appwrite.io/v1",
       "APPWRITE_PROJECT_ID": "your-project-id",
       "APPWRITE_DATABASE_ID": "your-database-id",
       "APPWRITE_COLLECTION_ID": "your-collection-id"
     }
   }
   ```

3. **Update launch.json** to read from settings:
   Already configured to read from `${env:VARIABLE_NAME}`

## Running the App

### Using VS Code UI

1. **Open Run and Debug panel**: Press `Ctrl+Shift+D` (Windows/Linux) or `Cmd+Shift+D` (Mac)

2. **Select configuration**: Use the dropdown at the top to choose:
   - "CountDownNow (Development)" - for normal development
   - "CountDownNow (Anonymous Mode)" - for testing without Appwrite
   - "CountDownNow (Chrome)" - to specifically run on Chrome
   - etc.

3. **Start debugging**: Press `F5` or click the green play button

### Using Keyboard Shortcuts

- `F5` - Start debugging with current configuration
- `Ctrl+F5` - Run without debugging
- `Shift+F5` - Stop debugging
- `Ctrl+Shift+F5` - Restart debugging

## Multiple Environments

### Development vs Production

The launch.json includes separate configurations for dev and prod:

**Development** uses these environment variables:
```json
"APPWRITE_PROJECT_ID": "${env:APPWRITE_PROJECT_ID}",
"APPWRITE_DATABASE_ID": "${env:APPWRITE_DATABASE_ID}",
"APPWRITE_COLLECTION_ID": "${env:APPWRITE_COLLECTION_ID}"
```

**Production** uses different variables:
```json
"APPWRITE_PROJECT_ID": "${env:APPWRITE_PROJECT_ID_PROD}",
"APPWRITE_DATABASE_ID": "${env:APPWRITE_DATABASE_ID_PROD}",
"APPWRITE_COLLECTION_ID": "${env:APPWRITE_COLLECTION_ID_PROD}"
```

**Setup**:

1. Set environment variables:
   ```powershell
   # Development
   $env:APPWRITE_PROJECT_ID = "dev-project-id"
   $env:APPWRITE_DATABASE_ID = "dev-database-id"
   $env:APPWRITE_COLLECTION_ID = "dev-collection-id"
   
   # Production
   $env:APPWRITE_PROJECT_ID_PROD = "prod-project-id"
   $env:APPWRITE_DATABASE_ID_PROD = "prod-database-id"
   $env:APPWRITE_COLLECTION_ID_PROD = "prod-collection-id"
   ```

2. Select appropriate configuration in Run and Debug panel

3. Press F5

## Debugging Features

### Breakpoints
- Click in the gutter (left of line numbers) to set breakpoints
- Breakpoints pause execution so you can inspect variables

### Debug Console
- View debug output in the Debug Console panel
- Execute Dart/Flutter commands while paused

### Variables Panel
- View current variable values
- Expand objects to see properties

### Call Stack
- See the sequence of function calls leading to current point
- Click frames to jump between stack levels

## Hot Reload & Hot Restart

While debugging:
- **Hot Reload**: Press `Ctrl+F5` or click ⚡ icon (preserves state)
- **Hot Restart**: Press `Ctrl+Shift+F5` or click 🔄 icon (resets state)

## Extensions Recommended

Install these VS Code extensions for better Flutter development:

1. **Flutter** (by Dart Code) - Essential
2. **Dart** (by Dart Code) - Essential
3. **Awesome Flutter Snippets** - Code snippets
4. **Pubspec Assist** - Dependency management
5. **Flutter Widget Snippets** - Widget shortcuts
6. **Error Lens** - Inline error highlighting

Install all at once:
```
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
code --install-extension Nash.awesome-flutter-snippets
code --install-extension jeroen-meijer.pubspec-assist
code --install-extension alexisvt.flutter-snippets
code --install-extension usernamehw.errorlens
```

## Tasks

The project can include custom tasks in `.vscode/tasks.json` for common operations:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Flutter: Get Packages",
      "type": "shell",
      "command": "flutter pub get",
      "problemMatcher": []
    },
    {
      "label": "Flutter: Clean",
      "type": "shell",
      "command": "flutter clean",
      "problemMatcher": []
    },
    {
      "label": "Flutter: Build Web",
      "type": "shell",
      "command": "flutter build web --release",
      "problemMatcher": []
    }
  ]
}
```

## Troubleshooting

### Environment Variables Not Loading

**Issue**: App shows "⚠️ NOT SET" for configuration

**Solutions**:
1. Check that variables are set in launch.json `env` section
2. Verify variable names match exactly (case-sensitive)
3. Restart VS Code after setting environment variables
4. Try hardcoding values in launch.json temporarily to test

### Can't Select Chrome Device

**Issue**: Chrome not available in device list

**Solutions**:
1. Enable web support: `flutter config --enable-web`
2. Run `flutter devices` to verify Chrome is available
3. Restart VS Code

### Hot Reload Not Working

**Issue**: Changes not appearing

**Solutions**:
1. Save the file first (`Ctrl+S`)
2. Use Hot Restart (`Ctrl+Shift+F5`) instead
3. Stop and restart debugging session

### Breakpoints Not Hitting

**Issue**: Breakpoints are ignored

**Solutions**:
1. Ensure file is saved
2. Check that code path is actually executed
3. Verify you're in debug mode (not running without debugging)
4. Try removing and re-adding the breakpoint

## Tips & Tricks

### Quick Configuration Switch
Add keyboard shortcuts for switching configurations:

1. Open Keyboard Shortcuts: `Ctrl+K Ctrl+S`
2. Search for "Debug: Select and Start Debugging"
3. Assign a shortcut (e.g., `Ctrl+Shift+D`)

### View Configuration in Code
Check if environment variables are loaded:

```dart
import 'package:count_down_now/core/app_config.dart';

void main() {
  print(AppConfig.configSummary);
  runApp(const CountDownNowApp());
}
```

### Auto-attach Debugger
Enable "Debug: Auto Attach" in settings to automatically attach debugger to Flutter processes.

### Use Logpoints Instead of print()
Right-click in gutter → Add Logpoint → Enter message
- Non-intrusive (no code changes)
- Automatically removed when done debugging

## Configuration Reference

### Environment Variables Used

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `APPWRITE_ENDPOINT` | No | `https://cloud.appwrite.io/v1` | Appwrite API endpoint |
| `APPWRITE_PROJECT_ID` | Yes | - | Your project ID (dev) |
| `APPWRITE_DATABASE_ID` | Yes | - | Database ID (dev) |
| `APPWRITE_COLLECTION_ID` | Yes | - | Collection ID (dev) |
| `APPWRITE_PROJECT_ID_PROD` | Yes* | - | Production project ID |
| `APPWRITE_DATABASE_ID_PROD` | Yes* | - | Production database ID |
| `APPWRITE_COLLECTION_ID_PROD` | Yes* | - | Production collection ID |

*Required only for production configuration

---

## Need Help?

- See [ENVIRONMENT_VARIABLES.md](../ENVIRONMENT_VARIABLES.md) for general environment variable setup
- See [QUICKSTART.md](../QUICKSTART.md) for getting started
- Check Flutter documentation: https://flutter.dev/docs
- VS Code docs: https://code.visualstudio.com/docs
