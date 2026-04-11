/// obj_game_controller - Alarm 4 (Конец демонстрации)

global.is_showing_starter = false;

// Если сейчас ход компьютера, запускаем его "раздумья" через полсекунды
if (global.current_turn == "computer") {
    alarm[1] = 30;
}