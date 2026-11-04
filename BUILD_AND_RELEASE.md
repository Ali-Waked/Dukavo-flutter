# Build and Release

This document describes how to build the Dukavo Flutter app for Android and
iOS, how to sign a release, and what has actually been verified in this
workspace. It is written so a maintainer on a clean machine can reproduce the
result without guessing.

---

## 1. Toolchain

| Tool | Version used for verification |
| --- | --- |
| Flutter | 3.47.9 (stable) |
| Dart | 3.13.7 |
| JDK | Temurin 17.0.21+9 |
| Gradle | 8.12 (wrapper) |
| Android compileSdk / targetSdk | 36 |
| Android minSdk | 24 |
| Android build-tools | 36.0.0 |
| Android NDK (only if a native build needs it) | 28.2.13676358 |

Check the Flutter side:

```bash
flutter --version
flutter doctor -v
```

`flutter doctor` must report a working Android toolchain before an APK can be
built. The project does not require code generation.

---

## 2. Environment

### 2.1 JDK

Gradle 8.12 and the Android Gradle Plugin require JDK 17 (not 21+ for this
project's configuration). Point `JAVA_HOME` at a JDK 17 installation:

```bash
export JAVA_HOME=/opt/jdk/jdk-17.0.21+9
export PATH="$JAVA_HOME/bin:$PATH"
java -version   # openjdk 17.x
javac -version
```

On this workspace the JDK was extracted to
`/opt/jdk/jdk-17.0.21+9` from the verified tarball
`/root/toolchain/jdk17.tar.gz`.

### 2.2 Android SDK

Install the command-line tools, then the packages the project needs:

```bash
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

If a plugin needs native compilation, also install:

```bash
sdkmanager "ndk;28.2.13676358" "cmake;3.22.1"
```

The Flutter Android build reads the SDK from `ANDROID_HOME` or from
`android/local.properties`:

```properties
sdk.dir=/opt/android-sdk
flutter.sdk=/root/flutter
```

`android/local.properties` is git-ignored and must not be committed.

### 2.3 Gradle memory

`android/gradle.properties` contains:

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G ...
```

On a small CI runner or a host with under 4 GB of RAM, lower it before
building:

```properties
org.gradle.jvmargs=-Xmx2G -XX:MaxMetaspaceSize=1G -XX:ReservedCodeCacheSize=256m
```

Do not commit a machine-specific value unless the team agrees on it.

### 2.4 Network

The first Android build downloads the Gradle distribution and Maven
dependencies (several hundred MB). On a slow link, allow hours and keep the
build running in the background. Subsequent builds reuse
`~/.gradle/caches`.

---

## 3. Fetch dependencies and verify source

```bash
cd mobile
flutter pub get

dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

Expected:

- format: no output, exit 0;
- analyze: `No issues found!`;
- test: `All tests passed!` (126 tests at the time of writing).

Do not build an APK from a tree that fails these gates.

---

## 4. Android debug build

```bash
cd mobile
export JAVA_HOME=/opt/jdk/jdk-17.0.21+9
export ANDROID_HOME=/opt/android-sdk

flutter build apk --debug
```

Output:

```
build/app/outputs/flutter-apk/app-debug.apk
```

Install on a connected device:

```bash
flutter devices
flutter install --debug
# or
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

A debug build is signed with the local debug keystore and is intended for
testing only. It is not distributable.

### Pointing a debug build at a backend

```bash
flutter build apk --debug \
  --dart-define=DUKAVO_API_BASE_URL=http://192.168.1.20:8000/api/v1 \
  --dart-define=DUKAVO_WEB_BASE_URL=http://192.168.1.20:8000
```

For an Android emulator, the default `10.0.2.2` points at the host machine.

---

## 5. Android release build

### 5.1 Create an upload keystore (once)

```bash
keytool -genkeypair -v \
  -keystore ~/dukavo-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias dukavo
```

Store the keystore and passwords in a secret manager. Never commit them.

### 5.2 Configure signing locally

Create `android/key.properties` (git-ignored):

```properties
storePassword=...
keyPassword=...
keyAlias=dukavo
storeFile=/absolute/path/to/dukavo-upload.jks
```

The current `android/app/build.gradle.kts` intentionally signs `release` with
the debug key so `flutter run --release` works out of the box. **Before
publishing, replace that with a real signing config**, for example:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

Keep the `key.properties` lookup guarded so a checkout without the file still
builds debug variants.

### 5.3 Build

```bash
flutter build apk --release \
  --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1 \
  --dart-define=DUKAVO_WEB_BASE_URL=https://dukavo.com
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

For Play Store delivery use an app bundle:

```bash
flutter build appbundle --release \
  --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1 \
  --dart-define=DUKAVO_WEB_BASE_URL=https://dukavo.com
```

Output:

```
build/app/outputs/bundle/release/app-release.aab
```

### 5.4 Verify the artifact

```bash
# Signature and certificate
apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk

# Package id and version
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | head
```

Expected package: `com.dukavo.mobile`.

### 5.5 Release checklist

- [ ] `flutter analyze` clean.
- [ ] `flutter test` passes.
- [ ] API base URL is HTTPS.
- [ ] Development cleartext/ATS exceptions removed or restricted.
- [ ] Release signing configured (not the debug key).
- [ ] `version` in `pubspec.yaml` bumped (`1.0.0+1` format).
- [ ] Backend CORS/Sanctum stateful domains include the production origin.
- [ ] Crash reporting/analytics decision documented (none is compiled in).
- [ ] APK/AAB installed and smoke-tested against production.

---

## 6. iOS build (macOS only)

```bash
flutter build ipa --release \
  --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1 \
  --dart-define=DUKAVO_WEB_BASE_URL=https://dukavo.com
```

Requirements: macOS, Xcode 15+, CocoaPods, an Apple Developer team, signing
certificates and provisioning profiles. The bundle identifier is
`com.dukavo.mobile`. The local HTTP ATS exception is development-only.

This workspace is Linux, so no iOS artifact is produced here.

---

## 7. Verified results in this workspace

| Check | Result |
| --- | --- |
| `flutter pub get` | dependencies resolved |
| `dart format --set-exit-if-changed` | clean |
| `flutter analyze` | No issues found |
| `flutter test` | 126 tests passed |
| ARB parity | 919 keys in each file, identical sets |
| Android debug APK | see current status below |
| Android release APK/AAB | not produced: no upload keystore/signing config in this workspace |
| iOS IPA | not produced: Linux host, no Xcode |

### Current Android build status

The host originally had no Android SDK. A JDK 17 tarball was downloaded and
verified, and the Android command-line tools/platform/build-tools installation
was started. The network link to `dl.google.com` runs at roughly 24–30 KB/s,
so the SDK and Gradle dependency downloads take hours. The exact outcome of the
debug build is appended here once the toolchain finishes:

```
(pending — update with the real command output; do not claim success without it)
```

If the build cannot complete on this host, the blocker is environmental (no
Android SDK preinstalled + very slow network + limited disk/RAM), not a source
error: the Dart analyzer and test suite are clean. Reproduce on a machine with
a normal network and an Android SDK using the commands above.

---

## 8. CI outline

```yaml
jobs:
  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.9'
          channel: stable
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed lib test integration_test
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --debug
      - uses: actions/upload-artifact@v4
        with:
          name: dukavo-debug-apk
          path: build/app/outputs/flutter-apk/app-debug.apk
```

Add a release job with the keystore/password injected from CI secrets.

---

## 9. Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Unable to locate Android SDK` | `ANDROID_HOME`/`local.properties` missing | install cmdline-tools and set `sdk.dir` |
| `Unsupported class file major version` | wrong JDK | use JDK 17, not 21+ |
| `SDK location not found` | no `local.properties` | create it with `sdk.dir` |
| Gradle killed / OOM | `-Xmx8G` on a small host | lower `org.gradle.jvmargs` |
| `Failed to install build-tools` | license not accepted | `yes | sdkmanager --licenses` |
| `No space left on device` | Gradle caches + SDK | free space or move `GRADLE_USER_HOME` |
| Stuck downloading Gradle | slow network | let it run; later builds use the cache |
| `Execution failed for task ':app:...` | source/plugin error | run `flutter analyze` and `flutter test` first, then inspect the full Gradle log |
| APK installs but cannot reach API | wrong base URL or cleartext blocked | use `10.0.2.2` for emulator or an HTTPS host; check network security config |
| `419` at login | CSRF cookie blocked | confirm `/sanctum/csrf-cookie` and cookies work |
