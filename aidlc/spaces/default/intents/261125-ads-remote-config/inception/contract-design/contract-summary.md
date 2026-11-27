# Tóm tắt hợp đồng: Quảng cáo và Remote Config

Nguồn: `unit-of-work.md`, `unit-of-work-dependency.md`, `components.md`, `requirements.md` và `contract-design-questions.md`. Mọi hợp đồng do `u1-ads-core` sở hữu, ba unit còn lại là bên dùng. (Q3 của contract-design)

## Bảng hợp đồng

| # | Provider Unit | Consumer | Mechanism | Owner |
|---|---------------|----------|-----------|-------|
| 1 | External: nhà phát triển đặt giá trị trên Firebase Remote Config | U1 (`AdsConfig`) | shared schema (bộ tham số Remote Config) | U1 |
| 2 | U1 (`AdMediator`) | U2 (`LevelGameController`, `GameScreen`), U3 (`GameScreen`) | interface trong cùng ứng dụng, bất đồng bộ | U1 |
| 3 | U1 (`AdsConfig`) | U4 (`AppUpdateChecker`, `ScoreShareService`) | shared schema (đối tượng cấu hình chỉ đọc) | U1 |
| 4 | U1 (`AdMediator`) | U1 (`AdNetworkAdapters`) | interface trong cùng ứng dụng, bất đồng bộ | U1 |

## Hợp đồng 1: Bộ tham số trên Firebase Remote Config

Bên đặt giá trị là bạn trên Firebase. Bên đọc là `AdsConfig`. Mọi bản ứng dụng đã phát hành đều đọc cùng bộ tham số này. (`requirements.md` FR1)

```yaml shared-schema
contract: remote-config-parameters
parameters:
  banner_start_visit:
    type: integer
    default: 3
    rule: số nguyên dương, ngược lại dùng mặc định
  reward_enabled:
    type: boolean
    default: true
  interstitial_every_n_starts:
    type: integer
    default: 3
    rule: số nguyên dương, ngược lại dùng mặc định
  ads_priority:
    type: string
    default: "admob,unity,applovin"
    rule: tên mạng cách nhau bằng dấu phẩy, tên lạ bị bỏ qua, rỗng hoặc thiếu thì dùng mặc định
  android_version:
    type: string
    default: ""
    rule: số cách nhau bằng dấu chấm, ví dụ 1.0.1, ngược lại coi như thiếu
  android_url:
    type: string
    default: ""
    rule: địa chỉ web hợp lệ, ngược lại coi như thiếu
  ios_version:
    type: string
    default: ""
  ios_url:
    type: string
    default: ""
on_invalid_value: dùng mặc định và ghi một dòng cảnh báo vào nhật ký của ứng dụng
```

- **Thay đổi tương thích**: chỉ thêm khóa mới. Không đổi ý nghĩa hay kiểu của khóa đã phát hành. Bản cũ bỏ qua khóa lạ. (Q1)
- **Độ trễ có hiệu lực**: tối đa khoảng 12 giờ, theo khoảng tải tối thiểu hiện có (NFR6).

## Hợp đồng 2: AdMediator cung cấp quảng cáo cho các màn hình

```yaml shared-schema
contract: ad-mediator
operations:
  banner:
    returns: BannerResult
    BannerResult:
      shown: widget banner đã tải, kèm chiều cao
      hidden: không hiện (chưa đến lần mở thứ banner_start_visit, hoặc chưa tải, hoặc lỗi)
  interstitial_if_due:
    description: gọi ngay sau khi người chơi bấm Start (PLAY hoặc PLAY AGAIN); tự tăng bộ đếm
    returns: InterstitialResult
    InterstitialResult:
      shown: quảng cáo đã hiện và đã đóng
      skipped: chưa đủ N lần bấm, hoặc không có quảng cáo, hoặc lỗi
  reward:
    description: gọi khi người chơi bấm nút reward
    returns: RewardResult
    RewardResult:
      earned: người chơi xem đủ quảng cáo
      closed_early: đóng sớm, không thưởng
      no_ad: không có quảng cáo khi bấm, người chơi vẫn được thưởng (ADR-007)
guarantees:
  - không ném lỗi ra ngoài; mọi lỗi SDK trở thành kết quả skipped, hidden hoặc no_ad
  - không chặn luồng giao diện
  - không hiện quảng cáo nào trước khi đồng ý của người dùng được xử lý
timeouts:
  per_network_seconds: 5
  on_timeout: coi như không có quảng cáo ở mạng đó và thử mạng kế
```

- **Bên dùng**: `HomeScreen` gọi `interstitial_if_due` (U1), `GameScreen` gọi `banner` (U3), `LevelGameController` gọi `reward` (U2). (`components.md`)
- **Thứ tự mạng**: theo `ads_priority` của hợp đồng 1. Hết thời hạn hoặc không có quảng cáo thì thử mạng kế. (Q2)

## Hợp đồng 3: Đối tượng cấu hình chỉ đọc của AdsConfig

```yaml shared-schema
contract: ads-settings
entity: AdsSettings
read_only: true
fields:
  bannerStartVisit: integer
  rewardEnabled: boolean
  interstitialEveryNStarts: integer
  adsPriority: list of string
  androidVersion: string
  androidUrl: string
  iosVersion: string
  iosUrl: string
guarantees:
  - luôn có đủ trường với giá trị đã được kiểm tra hoặc mặc định
  - không ném lỗi khi không tải được cấu hình
consumers:
  - AppUpdateChecker: androidVersion, iosVersion, androidUrl, iosUrl
  - ScoreShareService: androidUrl, iosUrl
```

## Hợp đồng 4: AdNetworkAdapter, interface của từng mạng

```yaml shared-schema
contract: ad-network-adapter
implementations: [admob, unity, applovin]
operations:
  preload: tải trước quảng cáo của loại banner, reward hoặc interstitial
  show: hiện quảng cáo đã tải và báo kết quả
results: [ready, no_fill, shown, earned, closed_early, error]
guarantees:
  - mọi lỗi SDK được bắt và trả về như một kết quả, không ném ra ngoài
  - hết thời hạn 5 giây thì AdMediator coi như no_fill
```

## Quy tắc sở hữu và thay đổi

- U1 sở hữu cả bốn hợp đồng. U2, U3 và U4 chỉ là bên dùng. (Q3)
- Thay đổi phá vỡ cần được bạn đồng ý trước khi U2, U3 và U4 sửa theo. Thay đổi chỉ thêm (thêm trường kết quả, thêm khóa Remote Config) an toàn vì bên dùng bỏ qua trường lạ.
- Tham số thiếu hoặc sai kiểu: dùng mặc định và ghi một dòng cảnh báo vào nhật ký ứng dụng, không báo cho người chơi. (Q4)

## Câu hỏi còn mở

| Contract | Question | Blocks |
|----------|----------|--------|
| 2 | Thời hạn 5 giây cho mỗi mạng nghĩa là trường hợp xấu nhất chờ tới 15 giây với ba mạng. Interstitial hiện ngay sau khi bấm Start nên chờ lâu sẽ gây khó chịu. Cần quyết định cách rút ngắn, ví dụ tải trước như reward | U1 |
| 2 | Thời hạn tổng tối đa cho một lần xin quảng cáo chưa được chốt | U1 |
| 3 | Dạng tên phiên bản như `1.0.0+2` hay `1.0` có được chấp nhận không, hay chỉ dạng số cách nhau bằng dấu chấm | U4 |

## Assumptions & Open Questions

None.
