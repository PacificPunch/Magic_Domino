/// obj_game_controller_b - Alarm 4 (Конец демонстрации)

// Отключаем блокировку кликов
global.is_showing_starter = false;
global.starter_tile = noone; // Сбрасываем стартер, чтобы он больше не мигал

// Если первый ходит компьютер, даем ему команду на старт
if (global.current_turn == "computer") {
    alarm[1] = 30; // Задержка в 0.5 сек перед тем, как бот кинет кость
}