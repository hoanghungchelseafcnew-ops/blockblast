# Thành phần giao diện: u2-reward-ads

Nguồn: `mockups.md`, `interaction-spec.md`, `design-system-mapping.md` và `functional-spec.md`. Mọi chuỗi giao diện chỉ dùng tiếng Anh.

## Cấu trúc trong lớp phủ Game Over (Journey)

```
GameOverOverlay
  Text "GAME OVER"
  Text "FINAL SCORE: <score>"
  Text "Target: <target>"
  Text "You will return to" + <level name>
  Text "Watch an ad to stay on this level"   (chỉ khi nút reward hiện)
  GemPrimaryButton "WATCH AD TO TRY AGAIN"   (chỉ khi nút reward hiện, key game-over-reward-button)
  PLAY AGAIN                                  (GemPrimaryButton khi không có nút reward, OverlayButton khi có)
  OverlayButton "SHARE SCORE"
  TextButton "BACK TO MENU"
```

## Thuộc tính mới của GameOverOverlay

| Thuộc tính | Kiểu | Mặc định | Ý nghĩa |
|-----------|------|----------|---------|
| `onWatchAd` | callback hoặc null | null | Null thì không có nút reward và không có dòng nhỏ |
| `watchAdBusy` | bool | false | Đang chờ quảng cáo; nút bị khóa |

Bản Endless (`GameOverOverlay.endless`) không có hai thuộc tính này nên không bao giờ có nút reward. (BR6.1)

## Trạng thái

| Trạng thái | Hiển thị |
|-----------|----------|
| Có nút reward | Nút chính WATCH AD TO TRY AGAIN ở trên, PLAY AGAIN chuyển thành nút phụ, thêm dòng nhỏ |
| Không có nút reward | Như hiện nay |
| Đang chờ quảng cáo | Nút reward bị khóa, các nút khác vẫn bấm được |

## Trợ năng

Vùng chạm tối thiểu 48dp (nút chính 56dp), nhãn đọc được bởi trình đọc màn hình. (`accessibility-checklist.md`)

## Assumptions & Open Questions

None.
