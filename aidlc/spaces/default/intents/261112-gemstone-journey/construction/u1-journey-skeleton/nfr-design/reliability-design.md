# Reliability Design — U1 `u1-journey-skeleton`

## Sources

- [nfr] `nfr-requirements/reliability-requirements.md` (NFR6.1–NFR6.9), `performance-requirements.md` (NFR5.2, NFR5.3)
- [fd] `functional-design/rules.md` (BR1.5, BR1.8, BR3.2, BR3.3, BR4.3, BR5.9)
- [Q2] `nfr-design-questions.md`

## D-R1 — Firebase init có giới hạn thời gian và bắt mọi lỗi

`FirebaseGateway.init()` trả về `FirebaseStatus { ok, failed, timeout }` và không bao giờ throw.
- Gọi `Firebase.initializeApp().timeout(1500ms)` (giá trị cụ thể, nằm trong ngân sách 3,5s, xử lý góp ý R-12 của NFR review).
- `catch (Object e)` để bắt cả `Exception` lẫn `Error` (NFR6.2).
- Trường hợp timeout: future gốc vẫn có thể chạy tiếp, nhưng kết quả bị bỏ qua trong phiên này. `RemoteConfigClient` không được dùng.

## D-R2 — Fetch Remote Config theo ngân sách còn lại

`budget = min(2000ms, deadline − now − 500ms)`. Nếu `budget ≤ 0` thì bỏ qua fetch (`fetch=skipped`).
- `fetchAndActivate().timeout(budget)`.
- Thành công: đọc `level_config`, `source = remote`.
- Timeout hoặc lỗi: đọc giá trị đang activate (nếu có): `source = cached`. Nếu không có hoặc không hợp lệ thì `source = default`.
- `RemoteConfigSettings(minimumFetchInterval: 12h, fetchTimeout: 2s)`.

## D-R3 — Hạn chót bootstrap

`AppBootstrap.run()`:
1. `t0 = Stopwatch.start()`, `deadline = 3500ms`.
2. `firebase = await FirebaseGateway.init()` (D-R1).
3. `config = firebase == ok ? await LevelConfigService.load(budget) : DefaultLevelConfig`, rồi validate (D-S1).
4. `catalog = LevelCatalog.from(config)`.
5. `await ProgressRepository.load()`. **Không timeout** (Q1 của NFR Requirements). Không tính vào 3,5s.
6. Log `config_source` và `bootstrap done` (D-O2).

Các bước 2–3 dùng chung `deadline`, nên tổng phần Firebase ≤ 3,5s.

## D-R4 — Hàng đợi ghi tuần tự và cổng "loaded"

```
_queue = Completer từ load()        // hàng đợi chỉ mở sau load()
write(op): _queue = _queue.then((_) => _runWithDirty(op)).catchError(log)
```

- Mọi lần ghi (và `flushDirty`) được nối vào cùng một chuỗi Future. Lời gọi trước `load()` tự động chờ (NFR6.8).
- `_runWithDirty`: đầu tiên ghi lại các key dirty mà bộ đếm còn < 3, sau đó mới ghi key mới. Lỗi thì đánh dấu dirty, tăng bộ đếm và log `warn`. Mỗi bước bắt lỗi riêng, nên chuỗi không bao giờ bị hỏng (BR3.3).
- `flushDirty()` (khi `AppLifecycleState.paused`): xếp vào cuối hàng đợi và thử mọi key dirty, bỏ qua bộ đếm.

## D-R5 — Đọc lỗi thì vào chế độ chỉ-đọc

`load()`:
- Thử `SharedPreferences.getInstance()` rồi đọc các key. Lỗi thì thử lại **một lần**.
- Vẫn lỗi: `readOnly = true`, cache dùng mặc định, log `warn` "[GJ][Progress][warn] read-only mode: <lỗi>".
- Khi `readOnly`, mọi `write(op)` đều bị bỏ qua. **Chỉ lần bỏ qua đầu tiên** log một dòng `warn`, các lần sau im lặng (Q2, xử lý góp ý R-11).
- Từng key hỏng (sai kiểu hoặc ngoài khoảng) thì dùng mặc định cho key đó và log một dòng. Việc này không làm cả repository vào chế độ chỉ-đọc.

## D-R6 — JourneyController không throw

`onLevelWon`:
1. Tính `PlayerProgress` mới (BR4.1/4.2) và gán vào cache của repository.
2. `try { await repo.savePlayerProgress(p) } catch (Object e) { log }`.
3. Trả `JourneyOutcome` tính từ cache.

## D-R7 — Resolving không kẹt

`LevelGameController._resolveWin()`:
```
status = resolving; notify
final save = journey.onLevelWon(level, score)
final anim = clearAnimationFuture ?? Future.value()
await Future.wait([anim, Future.any([save, Future.delayed(3s)])])
outcome = journey.lastOutcome  // tính từ cache
status = won; notify
```
Nếu hết 3 giây mà `save` chưa xong thì log `warn` (BR5.9).

## Graceful degradation (tổng hợp)

| Sự cố | Thiết kế | Kết quả |
|-------|----------|---------|
| Không mạng | D-R2 | cached/default |
| Firebase lỗi hoặc chậm | D-R1 | default |
| JSON sai | D-S1 | default |
| Ghi lỗi | D-R4 | dirty, thử lại |
| Đọc lỗi | D-R5 | chỉ-đọc |
| Save chậm | D-R7 | won sau 3s |

## Assumptions & Open Questions

None.
