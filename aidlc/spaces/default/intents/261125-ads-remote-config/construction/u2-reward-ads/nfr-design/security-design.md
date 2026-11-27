# Thiết kế bảo mật và độ đúng dữ liệu: u2-reward-ads

Nguồn: `security-requirements.md`, `functional-spec.md`, `rules.md` và `nfr-design-questions.md`. Không chứa mã triển khai.

| ID | Thiết kế |
|----|----------|
| NFR2.12 | Một khóa `pending_loss_level` trong `ProgressStore` lưu số thứ tự level của lần thua chưa ghi nhận. Ghi khi hết nước đi và chờ ghi xong trước khi cho bấm nút (Q1). Ghi nhận thua là một hàm duy nhất trong `LevelGameController`: chạy `JourneyController.onLevelLost`, rồi xóa khóa. Một cờ trong bộ nhớ chặn chạy hai lần trong cùng ván. Khi mở lại ứng dụng, nếu khóa còn thì `AppBootstrap` ghi nhận thua cho level đó và xóa khóa |
| NFR2.13 | Nhánh nhận thưởng không bao giờ gọi `onLevelLost`; chỉ lưu điểm cao (`saveHighScore`), xóa khóa, rồi bắt đầu lại cùng level |
| NFR2.14 | Mọi lỗi ghi hoặc xóa khóa được ghi qua `GjLog`. Nếu ghi khóa lỗi, các nút vẫn được mở sau khi ghi log để người chơi không bị kẹt |
| NFR3.2 | `LevelGameController` nhận `AdsService` qua constructor, mặc định `NoopAdsService`. Test dùng `FakeAdsService` |
| NFR7.2 | Test hiện có kiểm tra tiến trình bị hạ ngay khi thua sẽ được đổi sang kiểm tra hạ sau khi bấm PLAY AGAIN hoặc BACK TO MENU |

## Assumptions & Open Questions

None.
