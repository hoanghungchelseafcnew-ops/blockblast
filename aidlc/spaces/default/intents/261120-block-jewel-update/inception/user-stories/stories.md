# User Stories

Nguồn: requirements.md (FR1–FR4, NFR1–NFR7) của stage Requirements Analysis; mọi story truy ngược về các ID trong `traceability.json`.

## Nhóm 1. Màn khởi động (FR1)

### US1.1 Một màn khởi động liền mạch trên Android
As a Journey Player, I want to see only one startup screen, so that the app feels polished and starts without a flash of a different logo.
- **Ưu tiên:** Must Have
- **AC1.1.1** Given Android below 12, when I launch the app, then the window background is `#0F0C29` with no native logo before the in-app splash.
- **AC1.1.2** Given Android 12 or later, when I launch the app, then the system splash shows only the `#0F0C29` background (no custom splash image) and the in-app splash follows.
- **AC1.1.3** Given the in-app splash, when bootstrap finishes, then Home opens as before.
- **Phụ thuộc:** không. **INVEST:** độc lập, kiểm được bằng quan sát thiết bị.

### US1.2 Một màn khởi động liền mạch trên iOS
As a Journey Player, I want the iOS launch screen to match the in-app splash background, so that no logo flashes twice.
- **Ưu tiên:** Must Have
- **AC1.2.1** Given iOS, when I launch the app, then the launch screen shows only the `#0F0C29` background with no `LaunchImage`.
- **AC1.2.2** Given the launch screen, when the first Flutter frame renders, then the in-app splash appears without a visible color jump.

### US1.3 Cấu hình splash native không bị sinh lại
As a Journey Player, I want the app to never bring back the old native splash after a rebuild, so that the fix lasts.
- **Ưu tiên:** Should Have
- **AC1.3.1** Given `pubspec.yaml`, when I search it, then there is no `flutter_native_splash` section or dev dependency.
- **AC1.3.2** Given a clean build, when the app starts, then US1.1 and US1.2 still hold.

## Nhóm 2. Đổi tên Block Jewel (FR2)

### US2.1 Tên game hiển thị là Block Jewel
As a Journey Player, I want the game to be called Block Jewel everywhere I see its name, so that the brand is consistent.
- **Ưu tiên:** Must Have
- **AC2.1.1** Given the device home screen, when I look at the app icon label, then it reads "Block Jewel" (Android and iOS).
- **AC2.1.2** Given the app is open, when I see the task switcher title or the splash, then it reads "Block Jewel" / "BLOCK JEWEL".
- **AC2.1.3** Given the existing install, when I update, then my saved progress is kept (identifiers unchanged).

### US2.2 Dòng phụ Gemstone Journey được giữ
As a Journey Player, I want the "Gemstone Journey" subtitle to stay on the splash and Home, so that the gem theme remains clear.
- **Ưu tiên:** Should Have
- **AC2.2.1** Given the splash and Home, when they render, then they show "◆ Gemstone Journey ◆" under the title.

### US2.3 Văn bản chia sẻ nhắc đúng tên mới
As a Journey Player, I want shared text to say Block Jewel, so that friends see the right name.
- **Ưu tiên:** Must Have
- **AC2.3.1** Given the Game Over share, when I tap SHARE, then the text mentions "Block Jewel" and not "Block Crush".
- **AC2.3.2** Given any UI string, when I read it, then it is in English.

## Nhóm 3. Chia sẻ khi thắng (FR3)

### US3.1 Chia sẻ khi thắng level con
As a Journey Player, I want to share a screenshot when I pass a sub-level, so that I can show friends my progress.
- **Ưu tiên:** Must Have
- **AC3.1.1** Given the Victory screen for a sub-level, when it appears, then a SHARE button is visible.
- **AC3.1.2** Given the Victory screen, when I tap SHARE, then the OS share sheet opens with a full-screen screenshot including the board and the Victory overlay.
- **AC3.1.3** Given the share sheet, when it opens, then the text reads "I cleared <level name> with <score> points in Block Jewel!".
- **AC3.1.4** Given I have not tapped SHARE, when the level ends, then no image is saved or sent.

### US3.2 Chia sẻ khi mở khóa gem (level lớn)
As a Journey Player, I want to share when I unlock a gem, so that I can celebrate a big milestone.
- **Ưu tiên:** Must Have
- **AC3.2.1** Given the gem-unlock Victory screen, when it appears, then SHARE is visible beside CONTINUE.
- **AC3.2.2** Given I tap SHARE, when the sheet opens, then the screenshot includes the unlock text and animation frame.

### US3.3 Chia sẻ khi hoàn thành hành trình
As a Journey Player, I want to share when I finish level 36, so that I can show I completed the game.
- **Ưu tiên:** Must Have
- **AC3.3.1** Given the journey-complete Victory screen (no CONTINUE), when it appears, then SHARE and BACK TO MENU are both visible.
- **AC3.3.2** Given I tap SHARE, when the sheet opens, then the screenshot shows "JOURNEY COMPLETE!".

### US3.4 Chia sẻ lỗi không làm hỏng màn thắng
As a Journey Player, I want Victory to keep working if sharing fails, so that I never get stuck.
- **Ưu tiên:** Must Have
- **AC3.4.1** Given capture or sharing throws an error, when I tap SHARE, then the error is logged and the Victory screen stays usable.
- **AC3.4.2** Given sharing is open or failed, when I tap CONTINUE or BACK TO MENU, then it works once as before.

### US3.5 Chia sẻ ở Game Over vẫn hoạt động
As a Journey Player, I want the existing Game Over share to keep working, so that nothing regresses.
- **Ưu tiên:** Should Have
- **AC3.5.1** Given the Game Over screen, when I tap SHARE, then a screenshot with the score is shared as before.

## Nhóm 4. Thuật toán sinh khối (FR4)

### US4.1 Luôn có nước đi khi bảng chưa đầy
As a Journey Player, I want at least one tray block to fit when the board is not completely full, so that I do not lose unfairly.
- **Ưu tiên:** Must Have
- **AC4.1.1** Given a new tray where no block fits, when the tray is prepared, then exactly one randomly chosen block is replaced by a random block that fits (smallest is 1×1).
- **AC4.1.2** Given a board where even a 1×1 block cannot fit, when the tray is prepared, then the game ends as Game Over.
- **AC4.1.3** Given any board with at least one empty cell and many random seeds, when a tray is prepared, then at least one block fits.

### US4.2 Khối cứu giúp xóa dòng
As a Journey Player, I want the game to sometimes offer a block that clears a line, so that I can recover from tight boards.
- **Ưu tiên:** Must Have
- **AC4.2.1** Given a board where a block could clear at least one row or column, when a block is generated, then with probability `rescueRate` it is one that clears a line.
- **AC4.2.2** Given no block can clear a line, when a block is generated, then the normal rules apply.
- **AC4.2.3** Given level 1, when I read the rate, then it is 30%; at level 36 it is 10%.

### US4.3 Nhiều khối nhỏ khi bảng đầy
As a Journey Player, I want smaller blocks when the board is more than 60% full, so that I can keep playing.
- **Ưu tiên:** Must Have
- **AC4.3.1** Given more than 38 of 64 cells are filled, when blocks are generated, then the chance of small shapes is higher and of large shapes lower than at the same level with a board at or below 60%.
- **AC4.3.2** Given the board is at or below 60%, when blocks are generated, then the level's normal rates apply.

### US4.4 Độ khó tăng theo level
As a Journey Player, I want later levels to feel harder, so that the game stays interesting.
- **Ưu tiên:** Must Have
- **AC4.4.1** Given level 36 versus level 1 with the same empty board, when blocks are generated many times, then large shapes appear more often at level 36.
- **AC4.4.2** Given level 36 versus level 1, when I compare `rescueRate`, then it is lower at level 36.

### US4.5 Endless dùng cùng thuật toán
As an Endless Player, I want the same fair-tray rules, so that my run does not end by bad luck.
- **Ưu tiên:** Must Have
- **AC4.5.1** Given Endless mode, when a tray is prepared, then US4.1, US4.2 and US4.3 apply.
- **AC4.5.2** Given Endless mode, when blocks are generated, then a fixed mid-level difficulty (level 18) is used.

### US4.6 Thuật toán chỉnh được và test được
As a Journey Player, I want balance changes to be safe to ship, so that updates do not break fairness.
- **Ưu tiên:** Should Have
- **AC4.6.1** Given the rates and the 60% threshold, when a developer wants to tune them, then they live in one place in code.
- **AC4.6.2** Given a seeded random source, when the same board and level are used, then the same tray is produced.
- **AC4.6.3** Given special blocks, when blocks are generated, then ice and bomb rates and the color palette are unchanged.
