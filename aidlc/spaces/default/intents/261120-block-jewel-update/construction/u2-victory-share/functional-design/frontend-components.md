# Frontend Components: u2-victory-share

Nguồn: functional-spec.md, components.md.

## VictoryOverlay (sửa)
- **Props mới:** `Future<void> Function()? onShare`.
- **State mới:** `bool _sharing`.
- **UI:** `GemPrimaryButton` hoặc `OutlinedButton` với `key: Key('victory-share-button')`, nhãn `SHARE`, icon `Icons.share`, rộng 240, cao tối thiểu 48dp, đặt dưới nút CONTINUE hoặc BACK TO MENU. Ẩn khi `onShare == null`.
- **Hành vi:** bấm → nếu `_sharing` hoặc `_leaving` thì bỏ qua; đặt `_sharing = true`, chờ `onShare()`, rồi `_sharing = false` (nếu còn mounted).

## GameScreen (sửa)
- Truyền `onShare: () => widget.shareService.shareVictory(screenshot: _screenshotController, levelName: controller.level.displayName, score: controller.score)` vào `VictoryOverlay`.

## ScoreShareService (sửa)
- Thêm `Future<void> shareVictory({required ScreenshotController screenshot, required String levelName, required int score})`.
- `PlatformScoreShareService` dùng chung helper chụp và ghi file; hằng `gameName = 'Block Jewel'`.
- Văn bản thuần tạo bởi hàm tĩnh `victoryShareText(levelName, score)` và `scoreShareText(score)` để test.
