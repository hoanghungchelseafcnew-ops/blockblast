# Thiết kế bảo mật và độ tin cậy: u3-banner

Nguồn: `security-requirements.md`, `tech-stack-decisions.md`, `functional-spec.md`, `contract-summary.md` và `nfr-design-questions.md`. Không chứa mã triển khai.

| ID | Thiết kế |
|----|----------|
| NFR2.19 | `AdMediator.banner` trả `hidden` ngay khi đồng ý chưa được xử lý, không gọi mạng nào. Lựa chọn cá nhân hóa của `ConsentService` được truyền cho mọi lần tải banner, như interstitial và reward |
| NFR2.20 | Mỗi adapter bắt mọi lỗi SDK khi tải banner và trả "không có". Lỗi khi banner đã hiện (ví dụ SDK báo hiện thất bại) làm vùng banner chuyển sang ẩn. Mọi lỗi được ghi qua `GjLog` |
| NFR2.21 | Banner đã tải có thao tác giải phóng. Vùng banner gọi thao tác này khi màn chơi đóng, và cũng giải phóng banner nếu nó tải xong sau khi màn đã đóng |
| NFR2.22 | `AdUnitIds` có thêm ID banner. Bản debug dùng ID banner thử công khai của AdMob; ID phát hành để trống kèm TODO, nghĩa là mạng đó không có banner |
| NFR3.3 | `AdNetworkAdapter` có thêm thao tác tải banner trả về một đối tượng banner trừu tượng (phần tử giao diện, chiều cao, giải phóng). Bản giả `FakeAdNetwork` trả đối tượng giả, nên logic chọn mạng và vùng banner kiểm thử được không cần SDK |

## Assumptions & Open Questions

None.
