# Thành phần logic: u1-ads-core

Nguồn: `components.md`, `security-design.md`, `contract-summary.md` và `functional-spec.md`. Tài liệu này cho thấy mỗi quy tắc phi chức năng áp dụng ở đâu, làm cầu nối sang bước thiết kế hạ tầng.

## Danh sách thành phần logic

| Thành phần | Miền lỗi | Phạm vi ảnh hưởng nếu lỗi | Cách cô lập |
|-----------|----------|---------------------------|-------------|
| `AdsConfig` | Đọc cấu hình | Dùng mặc định, game chạy bình thường | Luôn trả đối tượng hợp lệ |
| `AdNetworkAdapters` (AdMob) | SDK AdMob | Mất quảng cáo từ AdMob, mạng kế được thử | Bắt mọi lỗi, thời hạn 5 giây |
| `AdNetworkAdapters` (Unity) | SDK Unity Ads | Mất quảng cáo từ Unity, mạng kế được thử | Bắt mọi lỗi, thời hạn 5 giây |
| `AdNetworkAdapters` (AppLovin) | SDK AppLovin | Mất quảng cáo từ AppLovin | Bắt mọi lỗi, thời hạn 5 giây |
| `ConsentService` | SDK đồng ý | Không có quảng cáo cho đến khi xử lý xong | Chạy nền, không chặn Splash |
| `AdCounters` | Kho lưu | Bộ đếm không lưu được, đếm lại từ giá trị hiện có | Bắt lỗi ghi, không ảnh hưởng game |
| `AdMediator` | Điều phối | Không có quảng cáo | Không ném lỗi, trả kết quả |
| `AppBootstrap` | Khởi động | Splash vẫn chuyển sau 3,5 giây | Hạn chót cứng |

## Tài nguyên dùng chung

- Một bản `AdsSettings` dùng chung, chỉ đọc.
- Một bản `InterstitialSlot` trong bộ nhớ, chỉ `AdMediator` ghi.
- Một kho lưu bộ đếm, chỉ `AdCounters` ghi.
- Không có tài nguyên máy chủ hay hạ tầng đám mây nào do đợt này thêm. Mọi thứ chạy trong ứng dụng, cộng Firebase Remote Config đã có.

## Thử lại và ghi nhật ký (từ nfr-design-questions.md)

- Khi tải trước interstitial thất bại, việc tải lại chỉ được bắt đầu khi người chơi bấm Start lần kế tiếp, tối đa một lần tải tại một thời điểm, không thử lại theo đồng hồ. (Q1)
- Sự kiện quảng cáo (hiện, không có quảng cáo, lỗi, hết thời hạn) chỉ được ghi một dòng vào nhật ký của ứng dụng (`GjLog`), không gửi lên Firebase Analytics. (Q2)

## Cầu nối sang hạ tầng

Không có thay đổi hạ tầng. Phần duy nhất chạm vào cấu hình bên ngoài là Firebase Remote Config (đã có) và các mục cấu hình nền tảng trong `AndroidManifest.xml` và `Info.plist` (đã nêu ở `tech-stack-decisions.md`).

## Assumptions & Open Questions

None.
