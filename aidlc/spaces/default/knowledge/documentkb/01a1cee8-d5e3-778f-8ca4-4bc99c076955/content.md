# Block Puzzle - Gemstone Journey Requirements

## 1. Tổng quan dự án

Nâng cấp game Block Puzzle Flutter hiện tại thành hệ thống chơi theo level với chủ đề đá quý (Gemstone Journey). Game sẽ có cơ chế tiến trình qua các cấp độ, tích hợp Firebase để quản lý cấu hình và thống kê.

---

## 2. Luật chơi

### 2.1 Cấu trúc Level
- **6 Level lớn (Major Levels):** Rose Quartz, Amethyst, Blue Topaz, Emerald, Sapphire, Ruby
- **6 Level con (Sub Levels) cho mỗi level lớn:** Rough Stone, Slabbing, Shaping, Sanding, Polishing, Bling
- **Tổng cộng:** 36 cấp độ (6 × 6)

### 2.2 Cơ chế tiến trình
- Đạt mốc điểm quy định → Lên level tiếp theo
- Không đạt điểm (game over) → Quay về level lớn gần nhất đã hoàn thành
  - Ví dụ: Đang chơi Amethyst > Shaping, nếu thua → quay về Amethyst > Rough Stone
  - Nếu chưa hoàn thành level lớn nào → quay về Rose Quartz > Rough Stone

---

## 3. Yêu cầu chức năng (Functional Requirements)

### FR-01: Classic Mode Only
- **Mô tả:** Chơi theo luật classic hiện tại của project
- **Chi tiết:**
  - Giữ nguyên gameplay xếp block hiện tại
  - Tạm ẩn/disable chức năng chơi theo thời gian (nếu có)
  - Chỉ kết thúc game khi không còn chỗ đặt block

### FR-02: Level Score System
- **Mô tả:** Hệ thống điểm theo level
- **Chi tiết:**
  - Mỗi level lớn và level con đều có mốc điểm để chiến thắng
  - Khi đạt mốc điểm → hiển thị màn hình victory → chuyển level tiếp
  - Điểm được tích lũy trong suốt lượt chơi của level đó
  - Reset điểm khi bắt đầu level mới

### FR-03: Firebase Remote Config Integration
- **Mô tả:** Cấu hình điểm từ Firebase
- **Chi tiết:**
  - Lưu cấu hình mốc điểm các level dạng JSON trên Firebase Remote Config
  - Fetch config khi khởi động app
  - Fallback: nếu không lấy được từ Firebase thì dùng config mặc định trong app
  - Cấu trúc JSON:
    ```json
    {
      "version": 1,
      "levels": {
        "rose_quartz": {
          "order": 1,
          "name": "Rose Quartz",
          "sub_levels": {
            "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 500},
            "slabbing": {"order": 2, "name": "Slabbing", "target_score": 800},
            "shaping": {"order": 3, "name": "Shaping", "target_score": 1200},
            "sanding": {"order": 4, "name": "Sanding", "target_score": 1500},
            "polishing": {"order": 5, "name": "Polishing", "target_score": 2000},
            "bling": {"order": 6, "name": "Bling", "target_score": 2500}
          }
        },
        "amethyst": {
          "order": 2,
          "name": "Amethyst",
          "sub_levels": {
            "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 3000},
            "slabbing": {"order": 2, "name": "Slabbing", "target_score": 3500},
            "shaping": {"order": 3, "name": "Shaping", "target_score": 4200},
            "sanding": {"order": 4, "name": "Sanding", "target_score": 5000},
            "polishing": {"order": 5, "name": "Polishing", "target_score": 6000},
            "bling": {"order": 6, "name": "Bling", "target_score": 7000}
          }
        },
        "blue_topaz": {
          "order": 3,
          "name": "Blue Topaz",
          "sub_levels": {
            "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 8000},
            "slabbing": {"order": 2, "name": "Slabbing", "target_score": 9500},
            "shaping": {"order": 3, "name": "Shaping", "target_score": 11000},
            "sanding": {"order": 4, "name": "Sanding", "target_score": 13000},
            "polishing": {"order": 5, "name": "Polishing", "target_score": 15000},
            "bling": {"order": 6, "name": "Bling", "target_score": 18000}
          }
        },
        "emerald": {
          "order": 4,
          "name": "Emerald",
          "sub_levels": {
            "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 20000},
            "slabbing": {"order": 2, "name": "Slabbing", "target_score": 24000},
            "shaping": {"order": 3, "name": "Shaping", "target_score": 28000},
            "sanding": {"order": 4, "name": "Sanding", "target_score": 33000},
            "polishing": {"order": 5, "name": "Polishing", "target_score": 40000},
            "bling": {"order": 6, "name": "Bling", "target_score": 48000}
          }
        },
        "sapphire": {
          "order": 5,
          "name": "Sapphire",
          "sub_levels": {
            "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 55000},
            "slabbing": {"order": 2, "name": "Slabbing", "target_score": 65000},
            "shaping": {"order": 3, "name": "Shaping", "target_score": 75000},
            "sanding": {"order": 4, "name": "Sanding", "target_score": 88000},
            "polishing": {"order": 5, "name": "Polishing", "target_score": 100000},
            "bling": {"order": 6, "name": "Bling", "target_score": 120000}
          }
        },
        "ruby": {
          "order": 6,
          "name": "Ruby",
          "sub_levels": {
            "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 140000},
            "slabbing": {"order": 2, "name": "Slabbing", "target_score": 165000},
            "shaping": {"order": 3, "name": "Shaping", "target_score": 195000},
            "sanding": {"order": 4, "name": "Sanding", "target_score": 230000},
            "polishing": {"order": 5, "name": "Polishing", "target_score": 280000},
            "bling": {"order": 6, "name": "Bling", "target_score": 350000}
          }
        }
      }
    }
    ```

### FR-04: Firebase Analytics Integration
- **Mô tả:** Thống kê traffic và hành vi người chơi
- **Chi tiết:**
  - Tracking các sự kiện:
    - `level_start`: Bắt đầu chơi level
    - `level_complete`: Hoàn thành level
    - `level_fail`: Thua level
    - `game_session`: Thời gian chơi mỗi phiên
  - Tracking user properties:
    - `current_major_level`: Level lớn hiện tại
    - `highest_level_reached`: Level cao nhất đạt được

### FR-05: Level Background Images
- **Mô tả:** Ảnh nền riêng cho mỗi level con
- **Chi tiết:**
  - Mỗi level con có 1 ảnh background riêng (tổng 36 ảnh)
  - Nguồn ảnh ưu tiên: Firebase Storage (URL trong Remote Config)
  - Fallback: ảnh fix cứng trong assets nếu không tải được từ Firebase
  - Khi đang chơi: background hiển thị mờ/blur phía sau game board
  - Ảnh thể hiện quá trình chế tác đá quý tương ứng với tên level con

### FR-06: Victory Celebration Screen
- **Mô tả:** Màn hình chúc mừng khi vượt level
- **Chi tiết:**
  
  **Khi vượt qua level con:**
  - Hiển thị full ảnh background của level đó (không blur, rõ nét)
  - Hiệu ứng chúc mừng đẹp mắt:
    - Confetti particles bay từ dưới lên
    - Glow effect xung quanh ảnh
    - Text animation "Level Complete!"
  - Phát nhạc/âm thanh chúc mừng
  - Thông báo: "Congratulations! [Tên Level Con] Completed!"
  - Hiển thị: Điểm đạt được / Mốc điểm yêu cầu
  - Nút "Continue" để chuyển level tiếp theo
  
  **Khi hoàn thành level lớn (Bling stage):**
  - Tất cả hiệu ứng của level con, cộng thêm:
    - Animation unlock viên đá quý mới
    - Hiệu ứng sparkle/shine đặc biệt
    - Thông báo: "🎉 [Tên Đá Quý] Unlocked!"
    - Hiển thị viên đá quý 3D xoay (nếu có thể)

### FR-07: Level Selection UI
- **Mô tả:** Giao diện chọn level
- **Chi tiết:**
  
  **Màn hình chọn Level Lớn:**
  - Hiển thị 6 viên đá quý đại diện cho 6 level lớn
  - Sắp xếp theo dạng journey/path
  - Trạng thái mỗi level:
    - 🔒 Locked: Màu xám, không thể click
    - 🔓 Unlocked: Màu sáng, có thể click
    - ✅ Completed: Màu sáng + icon check
  - Click vào level unlocked → mở màn hình chọn level con
  
  **Màn hình chọn Level Con:**
  - Hiển thị 6 level con của level lớn đã chọn
  - Mỗi level con hiển thị:
    - Thumbnail ảnh background (blur nếu locked)
    - Tên level con
    - Mốc điểm yêu cầu
    - Trạng thái: Locked/Unlocked/Completed
    - High score (nếu đã chơi)
  - Nút Back để quay lại màn hình level lớn

### FR-08: Progress Persistence
- **Mô tả:** Lưu tiến trình người chơi
- **Chi tiết:**
  - Sử dụng SharedPreferences (local storage)
  - Dữ liệu cần lưu:
    - `current_major_level`: Level lớn hiện tại
    - `current_sub_level`: Level con hiện tại
    - `completed_levels`: Danh sách level đã hoàn thành
    - `high_scores`: Điểm cao nhất mỗi level
    - `total_play_time`: Tổng thời gian chơi
  - Tự động lưu khi:
    - Hoàn thành level
    - Thoát game
    - Chuyển level

---

## 4. Yêu cầu phi chức năng (Non-Functional Requirements)

### NFR-01: Code Reusability
- **Mô tả:** Tận dụng tối đa code hiện có
- **Chi tiết:**
  - Giữ nguyên kiến trúc `lib/features/game/` hiện tại
  - Mở rộng các class hiện có (controllers, models) thay vì tạo mới
  - Tận dụng Provider pattern đã có trong project
  - Thêm mới feature `level_selection` trong `lib/features/`

### NFR-02: Asset Reuse
- **Mô tả:** Tận dụng assets hiện có
- **Chi tiết:**
  - Sử dụng âm thanh có sẵn:
    - `clear.wav` - Xóa hàng
    - `combo.wav` - Combo
    - `place.wav` - Đặt block
    - `gameover.wav` - Game over
  - Thêm mới (tối thiểu):
    - `victory.wav` hoặc `victory.mp3` - Âm thanh chúc mừng
    - `unlock.wav` - Âm thanh mở khóa level
  - Ảnh background:
    - Thêm 36 ảnh cho 36 level con
    - Có thể dùng placeholder ban đầu, thay thế sau
    - Đặt trong `assets/backgrounds/`

### NFR-03: Package Rename
- **Mô tả:** Đổi tên package Android
- **Chi tiết:**
  - Từ: `com.example.block_blast`
  - Thành: `com.h2.game.block_blast`
  - Files cần cập nhật:
    - `android/app/build.gradle` (applicationId)
    - `android/app/src/main/AndroidManifest.xml`
    - `android/app/src/debug/AndroidManifest.xml`
    - `android/app/src/profile/AndroidManifest.xml`
    - Kotlin/Java source directories
    - `google-services.json` (sau khi tạo Firebase project)

### NFR-04: Minimal Dependencies
- **Mô tả:** Hạn chế thêm dependencies mới
- **Chi tiết:**
  - Dependencies hiện có (tận dụng):
    - `provider` - State management
    - `shared_preferences` - Local storage
    - `audioplayers` - Âm thanh
    - `flutter_animate` - Animation
    - `google_fonts` - Fonts
  - Dependencies cần thêm:
    - `firebase_core` - Firebase base
    - `firebase_remote_config` - Remote config
    - `firebase_analytics` - Analytics
    - `cached_network_image` - Cache ảnh từ Firebase (optional)

### NFR-05: Performance
- **Mô tả:** Đảm bảo hiệu năng tốt
- **Chi tiết:**
  - Lazy load ảnh background từ Firebase
  - Cache ảnh đã tải để không tải lại
  - Preload ảnh level tiếp theo khi đang chơi
  - Giới hạn animation effects trên thiết bị yếu
  - Target: 60 FPS gameplay trên mid-range devices

### NFR-06: Offline Support
- **Mô tả:** Hỗ trợ chơi offline
- **Chi tiết:**
  - Game vẫn chơi được khi không có internet
  - Sử dụng config mặc định khi offline
  - Sử dụng ảnh fallback trong assets khi offline
  - Sync dữ liệu khi có kết nối trở lại

---

## 5. UI/UX Guidelines

### 5.1 Màu sắc chủ đề theo Level Lớn
| Level | Màu chính | Màu phụ |
|-------|-----------|---------|
| Rose Quartz | #FFB6C1 (Light Pink) | #FF69B4 (Hot Pink) |
| Amethyst | #9966CC (Amethyst) | #8B008B (Dark Magenta) |
| Blue Topaz | #4FC3F7 (Light Blue) | #0288D1 (Dark Blue) |
| Emerald | #50C878 (Emerald) | #228B22 (Forest Green) |
| Sapphire | #0F52BA (Sapphire) | #000080 (Navy) |
| Ruby | #E0115F (Ruby) | #8B0000 (Dark Red) |

### 5.2 Animation Guidelines
- Sử dụng `flutter_animate` cho các hiệu ứng
- Duration: 300-500ms cho transitions
- Easing: `Curves.easeInOut` cho smooth animations
- Victory effects: 2-3 giây cho full celebration

---

## 6. Technical Notes

### 6.1 Cấu trúc thư mục đề xuất
```
lib/
├── core/
│   ├── firebase/
│   │   ├── firebase_config.dart
│   │   ├── remote_config_service.dart
│   │   └── analytics_service.dart
│   └── ...
├── features/
│   ├── game/
│   │   ├── controllers/
│   │   │   └── game_controller.dart (update)
│   │   ├── models/
│   │   │   ├── level_model.dart (new)
│   │   │   └── progress_model.dart (new)
│   │   └── ...
│   ├── level_selection/
│   │   ├── screens/
│   │   │   ├── major_level_screen.dart
│   │   │   └── sub_level_screen.dart
│   │   └── widgets/
│   │       ├── level_card.dart
│   │       └── gemstone_widget.dart
│   └── victory/
│       ├── screens/
│       │   └── victory_screen.dart
│       └── widgets/
│           ├── confetti_widget.dart
│           └── gemstone_unlock_animation.dart
└── shared/
    └── ...

assets/
├── sounds/
│   ├── clear.wav
│   ├── combo.wav
│   ├── gameover.wav
│   ├── place.wav
│   ├── victory.mp3 (new)
│   └── unlock.wav (new)
├── backgrounds/
│   ├── rose_quartz/
│   │   ├── rough_stone.jpg
│   │   ├── slabbing.jpg
│   │   └── ... (6 images)
│   └── ... (6 folders)
└── gemstones/
    ├── rose_quartz.png
    ├── amethyst.png
    └── ... (6 images)
```

### 6.2 Firebase Setup Checklist
- [ ] Tạo Firebase project mới
- [ ] Enable Remote Config
- [ ] Enable Analytics
- [ ] Enable Storage (cho ảnh)
- [ ] Download `google-services.json`
- [ ] Cấu hình Android app với package mới

---

## 7. Acceptance Criteria

### AC-01: Level System
- [ ] Có thể chơi qua 36 level theo thứ tự
- [ ] Mốc điểm hiển thị đúng từ Remote Config
- [ ] Quay về đúng level khi thua

### AC-02: Victory Screen
- [ ] Hiển thị full ảnh background khi thắng
- [ ] Có hiệu ứng confetti và animation
- [ ] Phát nhạc chúc mừng

### AC-03: Firebase Integration
- [ ] Remote Config fetch thành công
- [ ] Analytics tracking đúng events
- [ ] Fallback hoạt động khi offline

### AC-04: Package Rename
- [ ] App build thành công với package mới
- [ ] Firebase connected với package mới

---

## 8. Phiên bản và Timeline

- **Phiên bản:** 2.0.0
- **Tên phiên bản:** Gemstone Journey
- **Ưu tiên:** High
