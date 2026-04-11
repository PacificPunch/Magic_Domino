/// obj_game_controller - Step Event

if (global.game_over) exit;

// Компьютер начнет "думать" только если:
// 1. Сейчас его ход
// 2. Таймер хода еще не запущен (alarm[1] < 0)
// 3. МЫ НЕ ПОКАЗЫВАЕМ СТАРТОВУЮ КОСТЬ (!global.is_showing_starter)
if (global.current_turn == "computer" && alarm[1] < 0 && !global.is_showing_starter) {
    alarm[1] = 60; // Задержка в 1 секунду перед ходом
}

if (keyboard_check_pressed(vk_escape)) {
    if (instance_exists(obj_domino_cross)) {
        with (obj_domino_cross) instance_destroy();
    }
    room_goto(rm_menu);
}