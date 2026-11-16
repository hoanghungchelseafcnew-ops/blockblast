# Business Rules — U1 `u1-journey-skeleton`

## Sources

- [req] `inception/requirements-analysis/requirements.md`
- [adr] `inception/domain-design/decisions.md` (ADR-001, 005, 006, 008, 009, 010)
- [contract] `inception/contract-design/contract-summary.md`
- [stories] `inception/user-stories/stories.md` (các story của U1)
- [Q1]–[Q4] `functional-design-questions.md`
- [review] `reviews/review-01.md` (R-01..R-10): bản này đã sửa theo các góp ý đó

```yaml
rules:
  # BR1 — Cấu hình level
  - id: BR1.1
    statement: Cấu hình được fetch và activate một lần trong ngân sách khởi động
    category: policy
    applies_to: LevelConfig
    trigger: app khởi động (bootstrap)
    logic: >
      Bootstrap có hạn chót tổng 3,5 giây tính từ lúc bắt đầu (BR1.8).
      Nếu Firebase đã khởi tạo xong, gọi fetchAndActivate với minimumFetchInterval 12 giờ, được chờ tối đa
      min(2 giây, thời gian còn lại trước hạn chót trừ 0,5 giây dành cho đọc dữ liệu cục bộ).
      Hết thời gian: dùng cấu hình đã activate trước đó nếu hợp lệ (source=cached), không thì mặc định (source=default). Không retry.
    violation: "không áp dụng; luôn có cấu hình"
    source: FR3.2
  - id: BR1.2
    statement: Cấu hình chỉ được chấp nhận khi hợp lệ toàn bộ
    category: validation
    applies_to: LevelConfig
    trigger: sau khi đọc JSON `level_config` từ bất kỳ nguồn nào (remote hoặc cached)
    logic: "IF JSON parse lỗi OR version thiếu hoặc < 1 OR không đúng 6 gem hợp lệ OR một gem không đúng 6 sub hợp lệ OR order trùng OR targetScore không phải số nguyên trong 1..10,000,000 THEN loại bỏ toàn bộ"
    violation: "dùng cấu hình mặc định (source=default) và log lỗi"
    source: FR3.3
  - id: BR1.3
    statement: URL ảnh được validate riêng cho từng level, trên mọi nguồn
    category: validation
    applies_to: SubLevelConfig.backgroundUrl
    trigger: khi validate cấu hình remote hoặc cached (cấu hình mặc định không có URL)
    logic: >
      Parse bằng bộ phân tích URI chuẩn. URL hợp lệ khi VÀ CHỈ KHI:
      scheme = https; không có userinfo; không có port hoặc port = 443;
      host (viết thường) = firebasestorage.googleapis.com, HOẶC host có dạng <nhãn>.firebasestorage.app
      (so khớp theo nhãn: phải có dấu chấm đứng ngay trước "firebasestorage.app" và ít nhất một nhãn không rỗng phía trước).
      Chuỗi rỗng hoặc chỉ khoảng trắng coi như không có URL.
      IF không hợp lệ THEN backgroundUrl = null cho level đó.
    violation: "chỉ bỏ URL của level đó, không loại cả cấu hình; log cảnh báo"
    source: FR5.2, ADR-006
  - id: BR1.4
    statement: Cấu hình đã lưu hoặc cache bị hỏng thì coi như mất
    category: policy
    applies_to: LevelConfig
    trigger: đọc cấu hình đã activate trước đó
    logic: "IF cấu hình đã activate không qua được BR1.2 THEN dùng mặc định, không thử khôi phục bản cũ"
    violation: "dùng mặc định và log lỗi"
    source: FR3.3a
  - id: BR1.5
    statement: Firebase lỗi hoặc treo không chặn việc chơi
    category: policy
    applies_to: LevelConfig
    trigger: Firebase.initializeApp thất bại hoặc không xong trong 1,5 giây
    logic: "IF khởi tạo Firebase lỗi OR quá 1,5 giây THEN bỏ qua Remote Config trong phiên này, dùng mặc định (source=default), tiếp tục vào Home"
    violation: "không hiện lỗi cho người chơi; log lỗi"
    source: Q1, NFR6
  - id: BR1.6
    statement: Mốc điểm không tăng dần chỉ là cảnh báo
    category: validation
    applies_to: LevelConfig
    trigger: khi validate cấu hình
    logic: "IF targetScore của level N+1 ≤ level N THEN log cảnh báo, vẫn chấp nhận"
    violation: "chỉ log"
    source: ADR-010
  - id: BR1.7
    statement: Nguồn cấu hình được ghi lại khi khởi động
    category: policy
    applies_to: LevelConfig.source
    trigger: bootstrap hoàn tất
    logic: "Log `config_source=<remote|cached|default>`"
    violation: "không áp dụng"
    source: contract E1
  - id: BR1.8
    statement: Ngân sách khởi động có giới hạn cứng
    category: constraint
    applies_to: AppBootstrap
    trigger: app khởi động
    logic: >
      Hạn chót tổng = 3,5 giây từ lúc bắt đầu bootstrap đến lúc chuyển sang Home.
      Firebase.initializeApp tối đa 1,5 giây (BR1.5). fetchAndActivate theo BR1.1. Đọc dữ liệu cục bộ tối đa 0,5 giây,
      quá thời gian thì dùng mặc định cho phần chưa đọc được.
      Khi hạn chót đến, mọi bước chưa xong bị bỏ qua (dùng cached hoặc default) và app vào Home.
    violation: "không bao giờ treo Splash; log bước bị cắt"
    source: ADR-010, review R-03

  # BR2 — Danh mục level
  - id: BR2.1
    statement: 36 level được đánh số theo thứ tự gem rồi sub
    category: calculation
    applies_to: Level.levelIndex
    trigger: dựng LevelCatalog
    logic: "levelIndex = (gemOrder − 1) × 6 + subOrder; gemOrder theo Rose Quartz, Amethyst, Blue Topaz, Emerald, Sapphire, Ruby; subOrder theo Rough Stone, Slabbing, Shaping, Sanding, Polishing, Bling"
    violation: "không áp dụng (catalog chỉ dựng từ cấu hình hợp lệ)"
    source: FR2.1
  - id: BR2.2
    statement: Level kế tiếp là levelIndex + 1; level 36 không có level kế tiếp
    category: calculation
    applies_to: LevelCatalog.next
    trigger: sau khi thắng
    logic: "IF levelIndex < 36 THEN next = level (levelIndex + 1) ELSE next = null"
    violation: "không áp dụng"
    source: FR2.5
  - id: BR2.3
    statement: Đường dẫn ảnh asset suy ra từ gem và sub
    category: calculation
    applies_to: Level.assetPath
    trigger: dựng LevelCatalog
    logic: "assetPath = assets/design/Level<gemOrder>/<subOrder>.jpg"
    violation: "không áp dụng"
    source: FR5.2
  - id: BR2.4
    statement: Danh mục level bất biến trong phiên
    category: constraint
    applies_to: LevelCatalog
    trigger: sau bootstrap
    logic: "Cấu hình activate muộn hơn chỉ có hiệu lực từ lần mở app tiếp theo"
    violation: "không áp dụng"
    source: ADR-010

  # BR3 — Lưu trữ
  - id: BR3.1
    statement: Không có hoặc hỏng dữ liệu tiến trình thì bắt đầu từ level 1
    category: validation
    applies_to: PlayerProgress
    trigger: ProgressRepository.load
    logic: "IF key `progress` không có OR parse lỗi OR currentLevelIndex ngoài 1..36 THEN PlayerProgress mặc định (level 1, rỗng). Trường lạ trong JSON bị bỏ qua. Phần tử completedLevels ngoài 1..36 bị bỏ. highestLevelReached = max(giá trị đọc được, currentLevelIndex)"
    violation: "dùng mặc định cho riêng key đó và log; không crash"
    source: FR8.3, contract E3
  - id: BR3.2
    statement: Mọi thao tác ghi được tuần tự hóa
    category: constraint
    applies_to: ProgressRepository
    trigger: mọi lời gọi ghi, kể cả flushDirty
    logic: "Mỗi lời gọi ghi (và flushDirty) được nối vào CÙNG một hàng đợi FIFO; chỉ chạy khi lời gọi trước đã xong; Future của lời gọi hoàn tất khi đã ghi đĩa hoặc khi lần ghi đó thất bại (sau khi đánh dấu dirty)"
    violation: "không áp dụng"
    source: ADR-009
  - id: BR3.3
    statement: Ghi lỗi thì đánh dấu dirty và thử lại
    category: policy
    applies_to: ProgressRepository
    trigger: một lần ghi đĩa thất bại
    logic: >
      Giữ giá trị đúng trong cache, đánh dấu key là dirty, đặt bộ đếm thử lại tự động = 0.
      Mỗi lần ghi kế tiếp (bất kỳ key nào) sẽ ghi lại các key dirty trước, mỗi lần tăng bộ đếm của key đó.
      Khi bộ đếm đạt 3 thì ngừng thử lại tự động cho key đó trong phiên.
      flushDirty (khi app chuyển sang paused) luôn thử ghi mọi key dirty một lần, KHÔNG phụ thuộc bộ đếm, và được xếp vào cuối hàng đợi (sau các lần ghi đang chờ).
      Ghi thành công thì xóa dirty và bộ đếm.
      Rủi ro còn lại (app bị kill khi vẫn còn key dirty) được chấp nhận.
    violation: "log lỗi; không throw; hàng đợi vẫn tiếp tục"
    source: contract C5, review R-05
  - id: BR3.4
    statement: Trạng thái tutorial được lưu qua repository
    category: policy
    applies_to: PlayerSettings.tutorialCompleted
    trigger: lần đặt khối đầu tiên khi tutorial đang hiện
    logic: "IF tutorialCompleted = false THEN hiện tutorial khi vào ván; sau lần đặt khối hợp lệ đầu tiên THEN setTutorialCompleted(true) và ẩn tutorial"
    violation: "không áp dụng"
    source: Q4, FR1.2
  - id: BR3.5
    statement: Giá trị tutorial hỏng thì coi như chưa xem
    category: validation
    applies_to: PlayerSettings.tutorialCompleted
    trigger: ProgressRepository.load
    logic: "IF key `tutorial_completed` có giá trị không phải bool THEN tutorialCompleted = false"
    violation: "log cảnh báo; tutorial hiện lại một lần (vô hại)"
    source: review R-10

  # BR4 — Hành trình (U1)
  - id: BR4.1
    statement: Thắng một level thì cập nhật tiến trình và chuyển sang level kế tiếp
    category: policy
    applies_to: PlayerProgress
    trigger: JourneyController.onLevelWon(level k)
    logic: >
      highestLevelReached nghĩa là level cao nhất người chơi từng MỞ được.
      Thêm k vào completedLevels (tập hợp, thêm lại không đổi gì).
      IF k < 36 THEN currentLevelIndex = k + 1 VÀ highestLevelReached = max(highestLevelReached, k + 1).
      IF k = 36 THEN theo BR4.2.
      Ví dụ: thắng level 5 lần đầu với highest=5 → completed có 5, current=6, highest=6.
      Thắng lại level 5 khi highest=9 (chỉ xảy ra ở U2 sau khi reset) → current=6, highest vẫn 9.
    violation: "không áp dụng"
    source: FR2.5, FR8.2, review R-02
  - id: BR4.2
    statement: Ở U1, thắng level 36 thì vẫn ở level 36
    category: policy
    applies_to: PlayerProgress
    trigger: onLevelWon khi levelIndex = 36
    logic: "Thêm 36 vào completedLevels; nextLevel = null; currentLevelIndex giữ 36; highestLevelReached = 36; journeyCompleted vẫn false (U2 sẽ đặt true)"
    violation: "không áp dụng"
    source: contract C1 u1_defaults
  - id: BR4.3
    statement: Kết quả thắng chỉ được trả về sau khi lưu xong, và không bao giờ throw
    category: constraint
    applies_to: JourneyController.onLevelWon
    trigger: onLevelWon
    logic: "Cập nhật cache trước, rồi await savePlayerProgress. Future<JourneyOutcome> hoàn tất khi ghi xong HOẶC khi ghi thất bại (đã đánh dấu dirty theo BR3.3). Mọi ngoại lệ bên trong bị bắt; outcome luôn được tính từ cache"
    violation: "log lỗi; vẫn trả outcome"
    source: ADR-008, US1.6

  # BR5 — Ván chơi level
  - id: BR5.1
    statement: Điểm của một lượt đặt khối
    category: calculation
    applies_to: BoardState.score
    trigger: đặt khối hợp lệ
    logic: "score += số ô của khối × 10; xác định dòng/cột đầy; IF linesCleared > 0 THEN comboStreak += 1 và score += linesCleared × 100 × comboStreak. Điểm được tính NGAY khi đặt, trước animation xóa dòng"
    violation: "không áp dụng"
    source: FR1.2
  - id: BR5.2
    statement: Combo reset khi lượt không xóa dòng
    category: calculation
    applies_to: BoardState.comboStreak
    trigger: đặt khối hợp lệ
    logic: "IF linesCleared = 0 THEN comboStreak = 0"
    violation: "không áp dụng"
    source: FR1.2
  - id: BR5.3
    statement: Đạt mốc điểm là thắng ngay, ưu tiên hơn hết nước đi
    category: policy
    applies_to: LevelRound.status
    trigger: ngay sau khi tính điểm của một lượt (BR5.1), trước animation xóa dòng
    logic: >
      IF score ≥ targetScore THEN status = resolving NGAY trong lượt đó (khóa input),
      kể cả khi còn nước đi, kể cả khi cùng lượt đó hết nước đi.
      Chuyển resolving → won khi CẢ HAI điều kiện xong: animation xóa dòng (nếu có) VÀ onLevelWon (hoặc timeout của BR5.9).
      Kiểm tra hết nước đi chỉ chạy khi KHÔNG thắng.
    violation: "không áp dụng"
    source: FR2.2, ADR-008, review R-01/R-07
  - id: BR5.4
    statement: Ngoài trạng thái playing, mọi thao tác chơi bị bỏ qua
    category: constraint
    applies_to: LevelRound
    trigger: status ∈ {resolving, won, lost, quit}
    logic: "Bỏ qua kéo-thả và đặt khối; ở resolving bỏ qua cả back; không xử lý thắng/thua lần hai"
    violation: "thao tác bị bỏ qua lặng lẽ (không phải lỗi)"
    source: ADR-008
  - id: BR5.5
    statement: Mốc điểm được chốt khi bắt đầu ván và luôn ≥ 1
    category: constraint
    applies_to: LevelRound.targetScore
    trigger: LevelGameController.start
    logic: "targetScore = max(1, level.targetScore) tại thời điểm start; không đổi đến hết ván"
    violation: "giá trị < 1 (không thể xảy ra sau BR1.2) được nâng lên 1 và log lỗi"
    source: ADR-010, review R-07
  - id: BR5.6
    statement: Phần trăm tiến độ làm tròn xuống
    category: calculation
    applies_to: LevelRound.progressPercent
    trigger: mỗi lần điểm đổi
    logic: "IF score ≥ target THEN 100 ELSE min(99, floor(score × 100 / target)); target ≥ 1 theo BR5.5"
    violation: "không áp dụng"
    source: FR11.1, refined-mockups Q2
  - id: BR5.7
    statement: Ở U1, hết nước đi thì vào trạng thái lost với Game Over cũ nhưng không đổi tiến trình
    category: policy
    applies_to: LevelRound
    trigger: không còn nước đi và score < target (sau animation xóa dòng)
    logic: >
      status = lost; hiện overlay Game Over hiện có (FINAL SCORE, SHARE, PLAY AGAIN, REVIVE nếu revived=false, BACK TO MENU).
      KHÔNG gọi onLevelLost, KHÔNG đổi PlayerProgress.
      REVIVE: xóa vùng 3×3 giữa bảng, revived = true, status = playing.
      PLAY AGAIN: tạo LevelRound MỚI (roundId mới, revived=false, score 0, combo 0, bảng trống) cùng level.
      BACK TO MENU hoặc back hệ thống: về Home.
    violation: "không áp dụng"
    source: Q2, review R-06 (sửa đổi contract C2 u1_defaults: U1 dùng `lost` cho overlay)
  - id: BR5.8
    statement: Ở U1, nút back khi đang chơi thì thoát ván mà không đổi tiến trình
    category: policy
    applies_to: LevelRound
    trigger: bấm ← hoặc back hệ thống khi status = playing (kể cả trong animation xóa dòng)
    logic: "status = quit, về Home, PlayerProgress không đổi (dialog xác nhận do U2 thêm)"
    violation: "không áp dụng"
    source: FR11.2 (phần U1)
  - id: BR5.9
    statement: Trạng thái resolving luôn kết thúc trong giới hạn thời gian
    category: constraint
    applies_to: LevelRound
    trigger: status = resolving
    logic: "IF onLevelWon chưa hoàn tất sau 3 giây THEN dùng outcome tính từ cache (tiến trình trong cache đã cập nhật; key đã hoặc sẽ được đánh dấu dirty), chuyển sang won và log cảnh báo"
    violation: "không bao giờ kẹt ở resolving"
    source: review R-01
  - id: BR5.10
    statement: Trong lúc animation xóa dòng, không nhận lượt đặt khối mới
    category: constraint
    applies_to: LevelRound.clearing
    trigger: animation xóa dòng 180ms
    logic: "clearing = true trong 180ms; kéo-thả bị bỏ qua; back vẫn được xử lý theo BR5.8 nếu status = playing; hết animation thì clearing = false"
    violation: "thao tác bị bỏ qua lặng lẽ"
    source: review R-07

  # BR6 — Nền tảng và phạm vi
  - id: BR6.1
    statement: Định danh ứng dụng mới trên Android và iOS
    category: constraint
    applies_to: cấu hình nền tảng
    trigger: build
    logic: "Android namespace và applicationId = com.h2.game.block_blast; iOS bundle = com.h2.game.blockBlast, RunnerTests = com.h2.game.blockBlast.RunnerTests"
    violation: "build không đạt DoD"
    source: FR14, NFR3
  - id: BR6.2
    statement: Không hardcode secret và hạn chế dependency
    category: constraint
    applies_to: mã nguồn
    trigger: review code
    logic: "Không có API key trong mã Dart; Firebase đọc từ file cấu hình nền tảng; U1 chỉ thêm firebase_core và firebase_remote_config"
    violation: "review không đạt"
    source: NFR11, NFR4
  - id: BR6.3
    statement: Chế độ Time Attack bị gỡ hoàn toàn
    category: constraint
    applies_to: mã nguồn
    trigger: review code
    logic: "Không còn timeattack, time attack, high_score_time, _timeLeft, _startTimer trong lib/ (không phân biệt hoa thường)"
    violation: "review không đạt"
    source: FR1.1
  - id: BR6.4
    statement: Chuỗi UI mới chỉ dùng tiếng Anh
    category: constraint
    applies_to: UI
    trigger: review code
    logic: "Mọi chuỗi hiển thị mới bằng tiếng Anh"
    violation: "review không đạt"
    source: NFR7

  # BR7 — Chất lượng
  - id: BR7.1
    statement: Logic nằm ngoài widget và kiểm thử được
    category: constraint
    applies_to: mã nguồn
    trigger: review code
    logic: "Cấu hình, catalog, tiến trình, hành trình, tính điểm và vòng đời ván nằm trong service/controller, có unit test không cần widget; mọi file tạo mới hoặc sửa có coverage dòng ≥ 80%"
    violation: "DoD không đạt"
    source: NFR1, NFR10, DoD-1, DoD-2
  - id: BR7.2
    statement: Không nuốt lỗi
    category: policy
    applies_to: mã nguồn
    trigger: mọi catch
    logic: "Mọi catch phải log lỗi và có fallback rõ ràng"
    violation: "review không đạt"
    source: DoD-4
```

## Tóm tắt

| Nhóm | Rules | Nội dung |
|------|-------|----------|
| BR1 Cấu hình | BR1.1–BR1.8 | Fetch trong ngân sách, validate toàn bộ, URL theo nhãn trên mọi nguồn, cache hỏng, Firebase lỗi hoặc treo, cảnh báo không tăng dần, log nguồn, **hạn chót khởi động 3,5s** |
| BR2 Danh mục | BR2.1–BR2.4 | Đánh số 1..36, level kế tiếp, đường dẫn asset, bất biến trong phiên |
| BR3 Lưu trữ | BR3.1–BR3.5 | Mặc định khi hỏng, một hàng đợi FIFO, dirty kèm bộ đếm và flush, tutorial qua repository, tutorial hỏng |
| BR4 Hành trình | BR4.1–BR4.3 | `highestLevelReached` = level cao nhất đã mở, ví dụ số, level 36 ở U1, trả kết quả sau khi lưu và không throw |
| BR5 Ván chơi | BR5.1–BR5.10 | Điểm tính trước animation, combo, thắng ngay (resolving trước animation), khóa thao tác, mốc ≥1, %, `lost` cho overlay ở U1, back, **timeout resolving 3s**, khóa lượt trong animation |
| BR6 Nền tảng | BR6.1–BR6.4 | Package ID, không secret và giới hạn dependency, gỡ Time Attack, tiếng Anh |
| BR7 Chất lượng | BR7.1–BR7.2 | Logic kiểm thử được và coverage, không nuốt lỗi |

**Sửa đổi contract C2 (nội bộ, đồng ý trong cùng thay đổi):** U1 dùng `status = lost` cho overlay Game Over cũ (BR5.7) thay vì "không bao giờ đặt `lost`". U2 giữ nguyên enum và chỉ thêm hành vi `onLevelLost`. Contract-summary đã được duyệt ở Inception nên không sửa lại. Sửa đổi này được ghi tại đây và áp dụng từ U1. Functional Design của U2 sẽ tham chiếu ghi chú này.

## Assumptions & Open Questions

None.
