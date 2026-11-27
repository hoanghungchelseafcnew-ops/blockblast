# Intent Statement: Quảng cáo và Remote Config trên Firebase

## Problem Statement

Game cần tạo doanh thu từ quảng cáo và cần điều chỉnh hành vi quảng cáo từ xa qua Firebase mà không phải phát hành lại ứng dụng. [Q1] [desc]

Khi người chơi thua, họ hiện bị đưa về Rough Stone thay vì được tiếp tục ở level hiện tại. Bản cũ của ứng dụng cũng không có cách nào báo cho người chơi biết cần cập nhật. [desc] [Q2]

## Target Customer

Người chơi cuối trên cả Android và iOS. [Q2]

## Success Metrics

- Doanh thu quảng cáo trên mỗi người dùng hoạt động hàng ngày tăng. [Q3]
- Tỷ lệ người chơi bấm xem reward ads khi thua. [Q3]
- Tỷ lệ người dùng cập nhật lên phiên bản mới sau khi thấy popup cập nhật. [Q3]
- Tỷ lệ giữ chân người chơi (retention) không giảm sau khi thêm quảng cáo. [Q3]

## Initiative Trigger

- Cần bắt đầu tạo doanh thu từ game. [Q4]
- Cần kéo người dùng đang dùng bản cũ cập nhật lên bản mới. [Q4]

## Initial Scope Signal

- Phạm vi do quy trình chọn (workflow-selected): `feature`. [scope]
- Ranh giới sản phẩm do người dùng xác nhận: đúng 6 hạng mục trong mô tả ban đầu, không thêm. [Q9]
  - Banner ở màn chơi, chỉ hiện từ lần vào thứ N (mặc định lần 3, N cấu hình được). [desc] [Q9]
  - Nút xem reward ads để tiếp tục ở level hiện tại, có cờ bật/tắt trên Firebase. [desc] [Q9]
  - Interstitial ads sau mỗi N lần bấm Start, N cấu hình trên Firebase. [desc] [Q9]
  - `ads_priority` quyết định thứ tự mediation cho banner, reward và interstitial. [desc] [Q9]
  - Cấu hình `android_version`, `android_url`, `ios_version`, `ios_url` để kiểm tra phiên bản và hiện popup cập nhật. [desc] [Q9]
  - Dùng `android_url` và `ios_url` trong nội dung chia sẻ. [desc] [Q9]

## Constraints Already Known

- Đã có tài khoản và ad unit cho AdMob, Unity và AppLovin. [Q7]
- Cần xử lý sự đồng ý của người dùng (GDPR/ATT hoặc tương đương). [Q8]
- Mọi chuỗi hiển thị trên UI của game dùng tiếng Anh, không hỗ trợ đa ngôn ngữ. [memory:M1]

## Assumptions & Open Questions

None.
