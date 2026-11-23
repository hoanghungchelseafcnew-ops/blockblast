# Domain Design Questions

Ngữ cảnh: game đã có `BoardEngine`, `BlockGenerator` (hàm tĩnh), `LevelGameController`, `EndlessGameController`, `ScoreShareService`, `VictoryOverlay`. Phần mới cần: chọn khối theo bảng và level, đường cong độ khó, nút chia sẻ ở Victory.

## Question 1
Nơi đặt logic chọn khối mới (đảm bảo có nước đi, khối "cứu", ưu tiên khối nhỏ khi bảng đầy):

A. Lớp mới `TrayGenerator` (không tĩnh, nhận `Random` tiêm vào) trong `lib/features/game/logic/`, thay thế `BlockGenerator.generateThree`; `BlockGenerator` giữ lại bảng hình và màu.
B. Mở rộng hàm tĩnh `BlockGenerator` thêm tham số (board, level).
X. Other (please specify)

[Answer]:A

## Question 2
Nơi đặt đường cong độ khó (level → tỉ lệ nhỏ/vừa/lớn và `rescueRate`):

A. Lớp thuần `DifficultyProfile` riêng trong `lib/features/game/logic/`, chứa các hằng số; `TrayGenerator` dùng nó.
B. Nằm trong `TrayGenerator`.
X. Other (please specify)

[Answer]:A

## Question 3
Cách `BoardEngine` biết level để sinh khay:

A. Controller truyền mức độ khó khi gọi `reset` và `refillTrayIfEmpty` (Journey truyền `levelIndex`, Endless truyền 18); engine vẫn không biết mốc điểm.
B. Engine giữ một thuộc tính `difficultyLevel` do controller gán.
X. Other (please specify)

[Answer]:A

## Question 4
Chia sẻ ở Victory:

A. Thêm phương thức `shareVictory({screenshot, levelName, score})` vào `ScoreShareService`, giữ `shareScore` cho Game Over.
B. Dùng chung `shareScore` và thêm tham số tùy chọn `levelName`.
X. Other (please specify)

[Answer]:A
