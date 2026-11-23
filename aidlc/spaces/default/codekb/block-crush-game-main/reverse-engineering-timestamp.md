# Reverse Engineering Timestamp

- **Ngày**: 2026-11-20 (intent 261120-block-jewel-update)
- **Commit**: a8eea3f7b8e667b9c29c88bd2feca0b0f2916cfe
- **Kiểu quét**: full rescan

## Scope of Analysis

```yaml
scope_version: 1
kind: partial
intent: 261120-block-jewel-update
fingerprint: 3287781ff0f601d2dbc5658e7eacc8267a01bc60
analyzed:
  paths:
    - lib/
    - test/
    - pubspec.yaml
    - analysis_options.yaml
    - android/app/src/main/AndroidManifest.xml
    - android/app/src/main/res/
    - android/app/build.gradle.kts
    - ios/Runner/Info.plist
    - ios/Runner/Base.lproj/LaunchScreen.storyboard
    - README.md
  components:
    - BlockBlastApp
    - SplashScreen
    - HomeScreen
    - GameScreen
    - EndlessGameScreen
    - LevelGameController
    - EndlessGameController
    - JourneyController
    - BoardEngine
    - BlockGenerator
    - BoardLogic
    - TurnResolver
    - BoardGeometry
    - VictoryOverlay
    - GameOverOverlay
    - ScoreShareService
    - LevelCatalog
    - LevelConfigService
    - ProgressRepository
    - AudioController
    - GemTheme
    - AppBootstrap
shallow:
  paths:
    - assets/
    - web/
    - linux/
    - macos/
    - windows/
    - coverage/
    - backup/
    - screenshots/
```
