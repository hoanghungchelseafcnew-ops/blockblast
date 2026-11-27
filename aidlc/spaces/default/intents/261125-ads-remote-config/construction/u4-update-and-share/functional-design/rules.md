# Quy tắc nghiệp vụ: u4-update-and-share

Nguồn: `requirements.md` (FR6, FR7, NFR4), `stories.md` (US5.1, US6.1), `unit-of-work.md` (U4), `unit-of-work-story-map.md`, `components.md` (`AppUpdateChecker`, `HomeScreen`, `ScoreShareService`), `contract-summary.md` (hợp đồng 3: `AdsSettings` chỉ đọc) và `functional-design-questions.md`.

```yaml
rules:
  - id: BR8.1
    statement: Chỉ so tên phiên bản dạng số.
    category: validation
    applies_to: AppUpdateChecker
    trigger: kiểm tra phiên bản
    logic: IF phiên bản cài đặt hoặc phiên bản trên cấu hình của nền tảng đang chạy không phải các số nguyên không âm cách nhau bằng dấu chấm (bỏ phần số build sau dấu +) THEN không có bản mới.
    violation: popup không hiện
    source: FR6.1, FR6.4
  - id: BR8.2
    statement: So từng phần số, phần thiếu coi là 0.
    category: calculation
    applies_to: AppUpdateChecker
    trigger: cả hai phiên bản hợp lệ
    logic: IF so lần lượt từng phần số từ trái sang phải (phần thiếu là 0) cho thấy phiên bản cấu hình lớn hơn THEN có bản mới; bằng hoặc nhỏ hơn thì không.
    violation: không áp dụng
    source: FR6.2, AC5.1.1, AC5.1.5
  - id: BR8.3
    statement: Đường dẫn cửa hàng phải là https đầy đủ.
    category: validation
    applies_to: AppUpdateChecker, ScoreShareService
    trigger: dùng android_url hoặc ios_url
    logic: IF đường dẫn của nền tảng đang chạy là URL tuyệt đối có scheme https và có tên máy chủ THEN hợp lệ; ELSE không hợp lệ.
    violation: popup không hiện; nội dung chia sẻ không có link
    source: FR6.4, FR7.2, Q3
  - id: BR8.4
    statement: Popup hiện tối đa một lần mỗi lần mở ứng dụng.
    category: constraint
    applies_to: HomeScreen
    trigger: vào màn Home
    logic: IF có bản mới AND đường dẫn hợp lệ AND popup chưa hiện trong lần mở này THEN hiện popup; lần mở gồm khởi động và mỗi lần quay lại từ nền được tính là một lần mở (BR5.3).
    violation: popup không hiện
    source: FR6.2, AC5.1.2, Q1
  - id: BR8.5
    statement: Hộp thoại đồng ý quảng cáo trước, popup cập nhật sau.
    category: policy
    applies_to: HomeScreen
    trigger: vào Home khi hộp thoại đồng ý đang chờ
    logic: IF luồng đồng ý quảng cáo chưa xong THEN chờ xong rồi mới hiện popup cập nhật.
    violation: không áp dụng
    source: Q2
  - id: BR8.6
    statement: UPDATE mở cửa hàng; LATER, back hoặc chạm ra ngoài thì đóng.
    category: policy
    applies_to: UpdatePopup
    trigger: người chơi bấm trên popup
    logic: IF bấm UPDATE THEN mở đường dẫn của nền tảng bằng trình mở ngoài rồi đóng popup; IF bấm LATER, back hoặc chạm ra ngoài THEN đóng popup.
    violation: không mở được thì ghi log và đóng popup, game chạy tiếp
    source: FR6.3, AC5.1.3, AC5.1.4
  - id: BR9.1
    statement: Thêm link cửa hàng ở dòng riêng cuối nội dung chia sẻ.
    category: calculation
    applies_to: ScoreShareService
    trigger: chia sẻ điểm hoặc chiến thắng
    logic: IF đường dẫn của nền tảng đang chạy hợp lệ (BR8.3) THEN nội dung là văn bản hiện có, xuống dòng, rồi đến link; ELSE nội dung giữ nguyên như hiện tại.
    violation: không áp dụng
    source: FR7.1, FR7.2, Q4
```

## Tóm tắt

| Quy tắc | Nội dung |
|---------|----------|
| BR8.1, BR8.2 | Kiểm tra và so phiên bản |
| BR8.3 | Đường dẫn hợp lệ (dùng chung cho popup và chia sẻ) |
| BR8.4, BR8.5 | Khi nào popup hiện |
| BR8.6 | Nút của popup |
| BR9.1 | Link trong nội dung chia sẻ |

## Assumptions & Open Questions

None.
