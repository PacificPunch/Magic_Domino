/// obj_game_controller_b - Step Event

if (global.game_over) exit;

// Компьютер начинает "думать"
if (global.current_turn == "computer" && alarm[1] < 0 && !global.is_showing_starter) {
    alarm[1] = 60; // Задержка в 1 секунду перед ходом компа
}

if (keyboard_check_pressed(vk_escape)) {
    // ВНИМАНИЕ: Проверь, чтобы название объекта костяшки совпадало с твоим _b
    if (instance_exists(obj_domino_b)) {
        with (obj_domino_b) instance_destroy();
    }
    room_goto(rm_menu);
}