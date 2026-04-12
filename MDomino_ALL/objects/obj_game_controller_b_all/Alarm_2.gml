/// obj_game_controller - Alarm 2 (Проверка состояния стола)

if (global.game_over) exit;

// 1. Проверка на обычную победу
if (ds_list_size(global.player_hand) == 0) {
    global.game_over = true;
    global.end_message = "Вы победили!";
    alarm[3] = 10;
    exit;
} else if (ds_list_size(global.computer_hand) == 0) {
    global.game_over = true;
    global.end_message = "Противник победил!"; // Изменено
    alarm[3] = 10;
    exit;
}

// 2. Проверка возможности хода текущего игрока
var current_hand = (global.current_turn == "player") ? global.player_hand : global.computer_hand;
var opp_hand = (global.current_turn == "player") ? global.computer_hand : global.player_hand;

if (!global.check_has_moves(current_hand)) {
    if (ds_list_size(global.bazar) == 0) {
        // У текущего игрока нет ходов и базар ПУСТ.
        if (!global.check_has_moves(opp_hand)) {
            // У обоих нет ходов - РЫБА
            global.resolve_fish();
        } else {
            // АВТОМАТИЧЕСКАЯ ПЕРЕДАЧА ХОДА
            if (global.current_turn == "player") {
                // Изменено
                show_message("У вас нет доступных ходов.\nХод переходит к противнику.");
                global.current_turn = "computer";
                alarm[1] = 30; 
            } else {
                // Изменено
                show_message("У противника нет доступных ходов.\nХод переходит к вам.");
                global.current_turn = "player";
                alarm[2] = 10; 
            }
        }
    } else {
        if (global.current_turn == "computer") alarm[1] = 30; 
    }
} else {
    // Ходы есть!
    if (global.current_turn == "computer") alarm[1] = 30; 
}