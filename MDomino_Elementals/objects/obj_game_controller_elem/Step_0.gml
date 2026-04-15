/// obj_game_controller_elem - Step Event

// Если игра окончена, прекращаем выполнение любой логики
if (global.game_over) exit;

// Логика хода ИИ (Компьютера)
if (global.current_turn == "computer" && alarm[1] < 0 && !global.is_showing_starter) {
    // Устанавливаем задержку, чтобы ИИ не ходил мгновенно
    alarm[1] = 60;
}

// Управление выходом
if (keyboard_check_pressed(vk_escape)) {
    if (instance_exists(obj_domino_elem)) {
        with (obj_domino_elem) instance_destroy();
    }
    room_goto(rm_menu);
}

// Проверка на "Рыбу" (Elemental Fish)
// Теперь "Рыба" будет случаться еще чаще, так как ДУБЛИ больше не спасают от конфликтов стихий
if (ds_list_size(global.bazar) == 0) {
    // Эти функции теперь автоматически учитывают, что дубли — это обычные стихии
    var player_can_move = global.check_has_moves(global.player_hand);
    var computer_can_move = global.check_has_moves(global.computer_hand);
    
    if (!player_can_move && !computer_can_move) {
        if (!global.game_over) {
            global.resolve_fish();
        }
    }
}