/// obj_game_controller - Step Event

if (global.game_over) exit;

// Компьютер начнет "думать" только если:
// 1. Сейчас его ход
// 2. Таймер хода еще не запущен (alarm[1] < 0)
// 3. МЫ НЕ ПОКАЗЫВАЕМ СТАРТОВУЮ КОСТЬ (!global.is_showing_starter)
if (global.current_turn == "computer" && alarm[1] < 0 && !global.is_showing_starter) {
    alarm[1] = 60; // Задержка в 1 секунду перед ходом
}