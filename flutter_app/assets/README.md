# Save your avatar here

Save your avatar image as **`avatar.png`** in this folder, with these requirements:

- File name: `avatar.png` (exactly)
- Size: 1024×1024 px recommended (square)
- Format: PNG with transparent or white background
- This same image is used for the app icon AND the launcher splash screen

After saving the file, regenerate the assets:

```powershell
cd flutter_app
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
