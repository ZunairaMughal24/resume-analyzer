# Setup Guide

## Android Configuration

In `android/app/build.gradle`, ensure:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

## iOS Configuration

In `ios/Runner/Info.plist`, add for file picker:
```xml
<key>NSDocumentsFolderUsageDescription</key>
<string>Required to access resume files</string>
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

## Running

```bash
flutter pub get
flutter run
```
