# Truy vết qua các unit

Nguồn: `requirements.md`, `stories.md` và `traceability.json` trong `code-generation/` của bốn unit.

## Kết quả

- **Tiêu chí chấp nhận (AC):** 37/37 có ít nhất một mục `OK` với tệp đích tồn tại. **Đạt.**
- **FR và NFR:** 35 trong 36 mã (FR1.1–FR8.2, NFR1–NFR7) không được ghi trực tiếp trong `traceability.json` của bước sinh mã. Chỉ NFR4 được ghi trực tiếp (u2, u4). Các mã này được truy vết gián tiếp qua story chứa chúng (bảng dưới), và mọi AC của các story đó đều `OK`. Theo quy tắc của stage, đây là **phát hiện**: các tệp `traceability.json` của bước sinh mã chưa ghi mã FR và NFR.

## Truy vết FR và NFR qua story

| Nhóm yêu cầu | Story | AC | Unit | Ví dụ tệp đích |
|--------------|-------|----|------|----------------|
| FR1.1–FR1.3, NFR1 | US1.1 | AC1.1.x | u1-ads-core | `lib/features/ads/services/ads_config.dart` |
| FR5.1–FR5.3 | US1.2 | AC1.2.x | u1-ads-core | `lib/features/ads/services/ad_mediator.dart` |
| FR8.1, FR8.2 | US1.3 | AC1.3.x | u1-ads-core | `lib/features/ads/services/consent_service.dart` |
| FR4.1–FR4.5, NFR2 | US2.1 | AC2.1.x | u1-ads-core | `lib/features/ads/services/ad_mediator.dart` |
| FR3.1–FR3.6, NFR2, NFR4 | US3.1 | AC3.1.1–AC3.1.7 | u2-reward-ads | `lib/features/journey/controllers/level_game_controller.dart` |
| FR2.1–FR2.4, NFR2 | US4.1 | AC4.1.1–AC4.1.6 | u3-banner | `lib/features/ads/widgets/ad_banner_slot.dart` |
| FR6.1–FR6.4, NFR4 | US5.1 | AC5.1.1–AC5.1.5 | u4-update-and-share | `lib/features/update/services/app_update_checker.dart` |
| FR7.1, FR7.2 | US6.1 | AC6.1.1–AC6.1.3 | u4-update-and-share | `lib/features/game/services/score_share_service.dart` |
| NFR3 | Mọi story | Test với bản giả | Cả bốn unit | `test/features/ads/ads_fakes.dart` |
| NFR5 | Không có story riêng | Hướng dọc giữ nguyên, không đổi trong đợt này | — | `lib/app_composition.dart` (`configureSystemUi`) |
| NFR6 | US1.1 | Khoảng tải 12 giờ giữ nguyên | u1-ads-core | `lib/core/firebase/firebase_remote_config_client.dart` |
| NFR7 | US3.1 | Test cũ vẫn xanh | u2-reward-ads | Toàn bộ suite |

## Ghi chú về yêu cầu đã thay đổi

FR3.1 và AC3.1.2 vẫn ghi là nút reward ẩn khi chưa có quảng cáo. ADR-007 đã thay đổi hành vi này: nút luôn hiện khi `reward_enabled` là true, và không có quảng cáo thì người chơi vẫn được thưởng. Mã theo ADR-007.

## Assumptions & Open Questions

None.
