# Reverse Engineering Timestamp

- **Ngày**: 2026-11-25 (intent 261125-ads-remote-config)
- **Commit**: 0cbba990f3a2101989911b5ceb6fcfc8379cf735
- **Kiểu quét**: focused scan trên kho đã cũ (STALE). Prior prose được giữ lại, các đường dẫn đã phân tích sâu ở lần trước (261120-block-jewel-update) được hạ xuống shallow vì không thể kiểm lại hết.

## Scope of Analysis

```yaml
scope_version: 1
kind: partial
intent: 261125-ads-remote-config
fingerprint: 7430ed35f345f237a2a72eb5ea5baba4b32f5b32
analyzed:
  paths:
    - lib/
    - test/
    - pubspec.yaml
    - android/app/src/main/AndroidManifest.xml
    - android/app/build.gradle.kts
    - ios/Runner/Info.plist
  components:
    - BlockBlastApp
    - HomeScreen
    - GameScreen
    - LevelGameController
    - JourneyController
    - GameOverOverlay
    - ScoreShareService
    - AppBootstrap
    - FirebaseRemoteConfigClient
    - FirebaseGateway
shallow:
  paths:
    - analysis_options.yaml
    - android/app/src/main/res/
    - ios/Runner/Base.lproj/LaunchScreen.storyboard
    - README.md
    - assets/
    - web/
    - linux/
    - macos/
    - windows/
    - coverage/
    - backup/
    - screenshots/
```
