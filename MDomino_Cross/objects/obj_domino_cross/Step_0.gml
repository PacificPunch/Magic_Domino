/// @description obj_domino_cross - Step Event

// 1. ПРОВЕРКА СОСТОЯНИЯ ИГРЫ
if (global.game_over) exit;

// 2. ОБРАБОТКА ВИДИМОСТИ (ИСПРАВЛЕНО)
// Кость должна быть видимой, если она у игрока, у КОМПЬЮТЕРА или на столе.
// Только кости в базаре должны оставаться невидимыми (visible = false).
if (owner == "player" || owner == "table" || owner == "computer") {
    visible = true;
} else {
    visible = false;
}

// 3. Логика плавного перемещения (если используете)
// x = lerp(x, target_x, 0.1);
// y = lerp(y, target_y, 0.1);