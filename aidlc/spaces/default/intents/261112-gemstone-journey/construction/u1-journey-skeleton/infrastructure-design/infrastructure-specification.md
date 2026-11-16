# Infrastructure Specification — U1 `u1-journey-skeleton`

## Sources

- [nfrd] `construction/u1-journey-skeleton/nfr-design/*.md` (D-R1, D-R2, D-SC1, D-S3)
- [nfr] `nfr-requirements/tech-stack-decisions.md` (NFR3.1, NFR3.2, NFR4.2)
- [feas] `ideation/feasibility/constraint-register.md` (chỉ gói miễn phí, không AWS)
- [prac] `inception/practices-discovery/team-practices.md` (build và phát hành thủ công, không git, không CI)
- [contract] `inception/contract-design/contract-summary.md` E1

U1 không cần server, container hay hạ tầng AWS. Hạ tầng chỉ gồm **Firebase project (gói Spark miễn phí)** do người dùng đã tạo, và cấu hình build trên hai nền tảng.

## Deployment

| Facet | Choice | Rationale |
|-------|--------|-----------|
| Compute model | App Flutter chạy trên thiết bị (client-only). Không có backend | Requirements và feasibility: không có server |
| Networking | Chỉ có egress HTTPS từ thiết bị tới các endpoint của Firebase Remote Config. Không có ingress | D-R2 |
| Storage | SharedPreferences trên thiết bị. Remote Config lưu cấu hình phía Firebase | ADR-009, contract E1, E3 |
| Environments | **Một** Firebase project dùng cho cả debug lẫn release, không có staging (Q1) | Một developer, chỉ gói miễn phí. Rủi ro: thử config trên Remote Config sẽ ảnh hưởng người chơi thật. Giảm thiểu: dùng điều kiện Remote Config hoặc chỉ publish khi đã kiểm |
| IaC | Không có. Firebase cấu hình thủ công trên console. JSON `level_config` mặc định lấy từ `DefaultLevelConfig` | Quy mô một người, không CI |
| Sizing | Không áp dụng | — |

## Infrastructure Services

| Service | Role | Configuration | Notes |
|---------|------|---------------|-------|
| Firebase project (Spark) | nền tảng | App Android `com.h2.game.block_blast`, app iOS `com.h2.game.blockBlast` | Người dùng đã tạo và đã đặt `google-services.json`, `GoogleService-Info.plist` đúng chỗ (đã kiểm tra) |
| Firebase Remote Config | config store | Parameter `level_config` (JSON string), giá trị mặc định = `DefaultLevelConfig`. Client: `minimumFetchInterval` 12h, `fetchTimeout` 2s | Người dùng tạo và publish (checklist X4). Contract E1 |
| Google Services Gradle plugin | build | `com.google.gms.google-services` khai báo trong `android/settings.gradle.kts` và áp dụng ở `android/app/build.gradle.kts` | Code Generation thêm |
| Firebase API key restriction | security | **Chưa thực hiện ở U1** (Q2=B). Khuyến nghị trước khi phát hành: giới hạn key Android theo package `com.h2.game.block_blast` cùng SHA-1, key iOS theo bundle `com.h2.game.blockBlast` | Rủi ro chấp nhận: key Firebase phía client vốn công khai. Giới hạn key chỉ chống việc dùng key sai mục đích. Xem lại ở giai đoạn Operation |

## Shared Infrastructure

| Shared Resource | Owner Unit | Consumer Units | Access Boundary |
|-----------------|-----------|----------------|-----------------|
| Firebase project | U1 (tạo cấu hình) | U4 (Storage URL), U5 (Analytics) | Mỗi unit chỉ dùng SDK riêng của mình, khởi tạo qua `FirebaseGateway` của U1 |
| Parameter `level_config` | U1 | U4 (thêm `background_url`) | Chỉ được thêm trường (contract E1) |

## Assumptions & Open Questions

- [assumption] Dùng một Firebase project cho cả debug và release. Nếu sau này cần tách môi trường, sẽ tạo project thứ hai và chọn file cấu hình theo build flavor (không thuộc U1).
