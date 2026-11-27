# Câu hỏi yêu cầu phi chức năng: u3-banner

Không cần thư viện mới: banner dùng lại ba SDK đã thêm ở `u1-ads-core` (`google_mobile_ads`, `unity_ads_plugin`, `applovin_max`). Đã chốt ở thiết kế chức năng: mỗi lần vào màn chơi tải một banner, thử mạng theo `ads_priority` với thời hạn 5 giây mỗi mạng, không tải được thì ẩn và chỉ thử lại ở lần vào sau (`functional-spec.md`). Hai câu dưới đây chốt các chỉ tiêu còn lại.

## Q1. Làm mới banner khi đang hiện

Mỗi mạng có thể tự đổi quảng cáo trong cùng vùng banner sau một khoảng thời gian (AdMob mặc định khoảng 60 giây, chỉnh trong bảng điều khiển của mạng). Làm mới nhiều thì doanh thu cao hơn, nhưng tốn thêm dữ liệu.

- A. Để mỗi mạng tự làm mới theo cài đặt trong bảng điều khiển của mạng đó
- B. Tắt làm mới: mỗi lần vào màn chơi chỉ một quảng cáo
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Kích thước banner của Unity và AppLovin

AdMob hỗ trợ banner thích ứng rộng bằng màn hình. Thư viện Unity chỉ có banner cỡ cố định (chuẩn là 320 x 50). AppLovin có banner thích ứng.

- A. AdMob và AppLovin dùng banner thích ứng; Unity dùng cỡ chuẩn 320 x 50, căn giữa
- B. Chỉ AdMob và AppLovin hiện banner; bỏ qua Unity cho banner (Unity vẫn dùng cho reward và interstitial)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Assumptions & Open Questions

- [assumption] Banner không làm chậm màn chơi: việc tải chạy nền, người chơi chơi được ngay khi vào màn (NFR2).
- [assumption] Banner không thu thập dữ liệu ngoài những gì SDK của mạng tự gửi, và tôn trọng lựa chọn đồng ý đã có (BR3.1, BR3.2).
