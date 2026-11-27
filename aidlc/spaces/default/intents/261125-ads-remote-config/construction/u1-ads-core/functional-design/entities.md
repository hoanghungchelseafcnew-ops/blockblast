# Thực thể: u1-ads-core

Nguồn: `components.md`, `contract-summary.md`, `unit-of-work.md` và `functional-design-questions.md`. Tài liệu không phụ thuộc ngôn ngữ lập trình.

```yaml
entities:
  - name: AdsSettings
    description: Cấu hình quảng cáo và phiên bản đã được kiểm tra, chỉ đọc, thuộc AdsConfig.
    attributes:
      - name: bannerStartVisit
        type: integer
        required: true
        default: 3
        min: 1
      - name: rewardEnabled
        type: boolean
        required: true
        default: true
      - name: interstitialEveryNStarts
        type: integer
        required: true
        default: 3
        min: 1
      - name: adsPriority
        type: list of network names
        required: true
        default: [admob, unity, applovin]
        allowed_values: [admob, unity, applovin]
      - name: androidVersion
        type: string
        required: true
        default: ""
      - name: androidUrl
        type: string
        required: true
        default: ""
      - name: iosVersion
        type: string
        required: true
        default: ""
      - name: iosUrl
        type: string
        required: true
        default: ""
    constraints:
      - Chỉ có một bản AdsSettings trong ứng dụng tại một thời điểm.
    relationships: []

  - name: AdCounterState
    description: Bộ đếm lưu bền của AdCounters.
    attributes:
      - name: appOpenCount
        type: integer
        required: true
        default: 0
        min: 0
      - name: startCount
        type: integer
        required: true
        default: 0
        min: 0
      - name: interstitialCarriedDue
        type: boolean
        required: true
        default: false
        description: Đánh dấu một lượt interstitial bị bỏ qua vì chưa sẵn sàng và cần bù ở lần bấm Start kế tiếp.
    constraints:
      - Các bộ đếm không bao giờ giảm và được giữ khi thoát ứng dụng.
    relationships: []

  - name: ConsentStatus
    description: Trạng thái đồng ý của người dùng, thuộc ConsentService.
    attributes:
      - name: state
        type: enum
        required: true
        allowed_values: [not_processed, required, granted, denied, not_applicable]
        default: not_processed
      - name: personalizedAllowed
        type: boolean
        required: true
        default: false
    constraints:
      - personalizedAllowed chỉ là true khi state là granted hoặc not_applicable.
    relationships: []

  - name: InterstitialSlot
    description: Trạng thái quảng cáo interstitial đã tải trước, thuộc AdMediator, chỉ tồn tại trong bộ nhớ.
    attributes:
      - name: ready
        type: boolean
        required: true
        default: false
      - name: network
        type: network name
        required: false
        description: Mạng đã tải được quảng cáo.
    constraints:
      - Mỗi lần hiện xong thì slot trở về chưa sẵn sàng và việc tải trước kế tiếp bắt đầu.
    relationships: []
```

## Tóm tắt

Có bốn thực thể. `AdsSettings` và `ConsentStatus` mô tả trạng thái đã kiểm tra, `AdCounterState` là phần duy nhất được lưu bền, và `InterstitialSlot` chỉ nằm trong bộ nhớ. Mỗi thực thể có đúng một thành phần sở hữu: `AdsConfig`, `AdCounters`, `ConsentService` và `AdMediator` theo thứ tự đó. (`components.md`)

## Assumptions & Open Questions

None.
