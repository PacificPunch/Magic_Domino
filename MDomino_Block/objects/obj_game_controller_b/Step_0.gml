/// obj_game_controller_b - Step Event

if (global.game_over) exit;

// Автоматический пропуск хода в режиме БЛОК
if (!global.is_showing_starter) {
    
    if (global.current_turn == "player") {
        // Проверяем, может ли игрок сходить
        if (!global.check_has_moves(global.player_hand)) {
            // Если и бот не может сходить - это РЫБА
            if (!global.check_has_moves(global.computer_hand)) {
                global.resolve_fish();
            } else {
                show_debug_message("У игрока нет ходов. Пропуск!");
                global.current_turn = "computer";
            }
        }
    } 
    else if (global.current_turn == "computer") {
        // Проверяем, может ли бот сходить
        if (!global.check_has_moves(global.computer_hand)) {
            // Если и игрок не может - это РЫБА
            if (!global.check_has_moves(global.player_hand)) {
                global.resolve_fish();
            } else {
                show_debug_message("У бота нет ходов. Пропуск!");
                global.current_turn = "player";
            }
        }
    }
}

// Выход в меню
if (keyboard_check_pressed(vk_escape)) {
    with (obj_domino) instance_destroy();
    room_goto(rm_menu);
}