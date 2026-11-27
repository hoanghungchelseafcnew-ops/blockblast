# Yêu cầu hiệu năng: u2-reward-ads

Nguồn: `functional-spec.md`, `requirements.md`, `contract-summary.md` và `nfr-requirements-questions.md`.

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR2.8 | Lớp phủ Game Over hiện ngay khi hết nước đi, không chờ quảng cáo hay ghi tiến trình | Kiểm thử widget: lớp phủ hiện trong cùng khung hình sau lần đặt khối cuối, không phụ thuộc kết quả quảng cáo | NFR2, BR6.2 |
| NFR2.9 | Quảng cáo reward được tải trước khi bắt đầu mỗi level ở Journey (sau khi đồng ý đã xử lý) và tải lại ngay sau mỗi lần hiện, tối đa một lần tải tại một thời điểm | Kiểm thử đơn vị: bắt đầu level gọi tải trước một lần, gọi hai lần liền không tạo hai lần tải | Q1 |
| NFR2.10 | Bấm nút mà quảng cáo chưa sẵn sàng thì thưởng ngay, không chờ | Kiểm thử đơn vị: quảng cáo đang tải thì `reward` trả `no_ad` ngay | Q2, ADR-007 |
| NFR2.11 | Mỗi mạng có thời hạn chờ 5 giây khi tải trước reward, như interstitial | Kiểm thử đơn vị với mạng treo | BR2.5 |

## Assumptions & Open Questions

None.
